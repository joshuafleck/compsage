class Survey < ActiveRecord::Base
  define_index do
    indexes job_title
    indexes description
    indexes sponsor.industry, :as => :industry
    
    has subscriptions.organization_id, :as => :subscribed_by
    has sponsor.latitude, :as => :latitude, :type => :float
    has sponsor.longitude, :as => :longitude, :type => :float
    has aasm_state_number

    set_property :latitude_attr   => "latitude"
    set_property :longitude_attr  => "longitude"
    
    # this will cause any changes to surveys between index rebuilds to be stored in a delta index until the next rebuild
    set_property :delta => true
  end

  belongs_to :sponsor, :class_name => "Organization"
  has_one  :invoice, :dependent => :destroy
  has_many :discussions, :dependent => :destroy
  has_many :invitations, :class_name => 'SurveyInvitation', :dependent => :destroy
  has_many :invitees, :class_name => 'Organization', :through => :invitations
  has_many :external_invitations, :class_name => 'ExternalSurveyInvitation'
  has_many :internal_and_external_invitations, :class_name => 'Invitation'
  has_many :questions, :dependent => :destroy, :order => "position"
  has_many :top_level_questions,
    :class_name => 'Question',
    :order => 'position',
    :conditions => {:parent_question_id => nil}
  has_many :responses, :through => :questions
  has_many :participations
  has_many :subscriptions, :class_name => 'SurveySubscription', :dependent => :destroy
  has_many :subscribed_organizations, :through => :survey_subscriptions, :source => :organization
    
  validates_presence_of :job_title, :on => :update
  validates_length_of :job_title, :maximum => 128, :on => :update
  validates_presence_of :days_running, :on => :update
  validates_presence_of :sponsor
  validate_on_update :questions_exist

  named_scope :since_last_week, Proc.new { {:conditions => ['end_date > ?', Time.now]} }
  named_scope :recent, :order => 'surveys.created_at DESC', :limit => 10
  named_scope :most_recent,  # used by the Invoice initializer
    :order => 'end_date DESC', 
    :conditions => 'end_date IS NOT NULL', 
    :limit => 1
  named_scope :closed, :conditions => ['aasm_state = ? OR aasm_state = ?', 'finished', 'stalled']
  named_scope :not_finished, :conditions => "aasm_state <> 'finished'"
  named_scope :not_pending, :conditions => "aasm_state <> 'pending'"
  named_scope :running_or_pending, :conditions => ['aasm_state = ? OR aasm_state = ?', 'running', 'pending']
  named_scope :running_or_stalled, :conditions => 'aasm_state = "running" OR aasm_state = "stalled"'
  named_scope :deletable, :conditions => ['aasm_state = ? OR aasm_state = ?', 'stalled', 'pending']
  named_scope :finished, :conditions => "aasm_state = 'finished'"
  named_scope :running, :conditions => "aasm_state = 'running'"
  
  after_create :add_sponsor_subscription, :add_default_questions
  before_destroy :cancel_survey
  before_save :set_aasm_state_number, :recalculate_end_date
  
  attr_accessor :days_to_extend
  
  ########### State Machine Configuration: START ############
    
  state_machine 'aasm_state', :initial => :pending do
    after_transition :pending => :running,  :do => [:send_invitations, :set_start_and_end_dates]
    after_transition :stalled => :running,  :do => :email_rerun_message
    after_transition any => :stalled,       :do => :email_failed_message
    after_transition any => :billing_error, :do => :email_billing_error 
    after_transition any => :finished,      :do => :email_results_available

    event :billing_info_received do
      transition :pending => :running
    end

    event :finish do
      transition :running => :finished,      :if => [:closed?, :full_report?, :billing_successful?]
      transition :running => :billing_error, :if => [:closed?, :full_report?]
      transition :running => :stalled,       :if => [:closed?]
    end

    event :rerun do
      transition :stalled => :running, :if => :can_be_rerun?
    end

    event :billing_error_resolved do
      transition :billing_error => :finished
    end

    event :finish_with_partial_report do
      transition :stalled => :finished,      :if => [:closed?, :full_report?, :billing_successful?]
      transition :stalled => :billing_error, :if => [:closed?, :enough_responses?]
    end
  end

  # hack, for filtering surveys by aasm_state in sphinx
  AASM_STATE_NUMBER_MAP = {
    'pending' => 0,
    'running' => 1,
    'stalled' => 2,
    'billing_error' => 3,
    'finished' => 4
  }

  ############### AASM Configuration: END ###################
       
  # the minumum number of days a survey can be extended
  MINIMUM_DAYS_TO_EXTEND = 3
  # the maximum number of days a survey can be running for
  MAXIMUM_DAYS_TO_RUN = 21
  # the number of participations required to provide results for each question
  REQUIRED_NUMBER_OF_PARTICIPATIONS = 5

  # Default set of questions to prepopulate when sponsoring a survey. This will find the PDQs when the model is first
  # loaded, meaning changes to PDQs will require a server bounce.
  DEFAULT_QUESTIONS = [
    PredefinedQuestion.find_by_name('Base salary'),
    PredefinedQuestion.find_by_name('Salary range')
  ]

  def closed?
    Time.now > end_date
  end
  
  def open?
    !closed?
  end
  
  # Retrieve the number of days to run the survey, 7 is the default
  def days_running
    self[:days_running] || 7
  end

  # a survey can be rerun if there are enough days left to accomodate the minimum run length 
  # (and the survey is currently stalled)
  def can_be_rerun?
    can_be_extended? && stalled?
  end
  
  # determines if there are enough days left to accomodate the minimum run length
  def can_be_extended?
    days_until_extension_deadline >= MINIMUM_DAYS_TO_EXTEND
  end
  
  # this will determine the maximum number of days the survey can be extended for
  # 7 days is default, but it may be less if nearing the extension deadline
  def maximum_days_to_extend
    [days_until_extension_deadline, 7].min
  end
  
  def extension_deadline
    self.start_date + MAXIMUM_DAYS_TO_RUN.days
  end

  # the number of days the survey can be extended, if the survey is running, base this off of the end date
  # if the survey is stalled, base this off of the current date (the end date may be many days past)
  def days_until_extension_deadline
    extension_deadline.to_date - (self.running? ? self.end_date.to_date : Date.today)
  end

  # The date that the survey began running, it may not be set, so use the current time as a substitute
  def start_date
    self[:start_date] || Time.now
  end
  
  # all data should be reported as of this date
  def effective_date
    (self.start_date - 90.days).to_date
  end
  
  # returns a sorted list of all (survey and external_survey) invitations
  def all_invitations(include_sponsor = false)
    invitations = self.internal_and_external_invitations.not_pending.all
    invitations << SurveyInvitation.new(:invitee => self.sponsor) if include_sponsor
    invitations.sort    
  end
  
  # determine if the survey had adequate invitations for providing results
  def enough_invitations?
    [self.all_invitations(true).size,self.participations.size].max >= REQUIRED_NUMBER_OF_PARTICIPATIONS
  end
  
  # determine the recommended number of invitations necessary to provide results
  def recommended_number_of_invitations
    REQUIRED_NUMBER_OF_PARTICIPATIONS - [self.all_invitations(true).size,self.participations.size].max
  end
  
  # find all custom questions, mark all as 'included'
  def custom_questions
    self.questions.find_all{|q| !q.custom_question_type.blank?}.each{|q| q.included = "1"}
  end
  
  def enough_participations?
    participations.count >= REQUIRED_NUMBER_OF_PARTICIPATIONS
  end
  
  def enough_responses?
    self.enough_participations? && !self.no_reportable_questions?
  end
  
  # determine if all questions can be reported
  def full_report?
    self.questions.each do |question|
      return false unless question.adequate_responses?
    end
    
    return true
  end
  
  # determine if the report would contain any data
  def no_reportable_questions?
    !self.questions.any?(&:adequate_responses?) 
  end
  
  def reportable_questions
    self.questions.find_all{|q| q.adequate_responses?}
  end

  def to_s
    job_title
  end
   
  # Same price for all surveys for now.  This is in cents.
  def price
    12900
  end  
  
  private
    
  # TODO: Figure out who to email...
  def email_failed_message
    Notifier.deliver_survey_stalled_notification(self)
  end
  
  # email all participants (so they know they may be receiving results), all pending invitees, external invitees
  def email_rerun_message    
    self.participations.each do |p| 
      Notifier.deliver_survey_rerun_notification_participant(self,p.participant) unless p.participant == self.sponsor
    end 
    self.invitations.pending.each do |i| 
      Notifier.deliver_survey_rerun_notification_non_participant(self,i.invitee)
    end
    self.external_invitations.each do |e|
      Notifier.deliver_survey_rerun_notification_non_participant(self,e) unless self.participations.collect{|p| p.participant}.include?(e)
    end
  end
  
  # Send email informing respondants that the results are available.
  def email_results_available
    participants = participations.collect { |p| p.participant } 
    # because has_many :through doesn't work backwards w/ polymorphism :/
    
    participants.each do |participant|
      Notifier.deliver_survey_results_available_notification(self, participant)
    end

    Notifier.deliver_survey_results_available_notification(self, sponsor) unless participants.include?(sponsor)
  end

  # notify the participants that the sponsor is not rerunning the survey
  def email_not_rerunning_message
    participations.collect(&:participant).each do |participant|
      Notifier.deliver_survey_not_rerunning_notification(self, participant)
    end
  end
 
  def email_billing_error
    # TODO: Implement
  end
    
  # Handles what all needs to be done to cancel and then destroy a survey.
  # Participations are deleted manually here because otherwise the participations will be
  # destroyed before we actually enter this callback, so their dependent option cannot be
  # set.
  def cancel_survey
    email_not_rerunning_message
    participations.destroy_all
    invitations.destroy_all
    external_invitations.destroy_all
  end

  # Creates a survey subscription for the survey sponsor.
  def add_sponsor_subscription
    s = subscriptions.create!(:organization => sponsor, :relationship => 'sponsor')
  end
  
  def set_start_and_end_dates 
    self.start_date = Time.now
    self.end_date = self.start_date + days_running.to_i.days
    self.save # i noticed some trouble with sending invites without the save
  end
    
  # Calls the billing routine and returns whether or not billing was successful.
  def billing_successful?
    # if we are paying by c.c. bill the card
    if self.invoice.paying_with_credit_card? then
      bill_sponsor
    # if we are paying by invoice, email the invoice to the sponsor
    else
      Notifier.deliver_invoice(self)
      true
    end
  end

  # Attempts to bill the survey sponsor.  Returns whether or not the operation succeeded.
  def bill_sponsor
    begin
      Gateway.bill_survey_sponsor(self)
      return true
    rescue Exceptions::GatewayException => exception
      self.billing_error_description = exception.message
      return false
    end
  end
  
  # Validates whether or not questions have been chosen.
  def questions_exist
    errors.add_to_base("You must choose at least one question to ask") if questions.empty?
  end
  
  # Set the aasm state number using the current aasm_state (hack for survey sphinx search filter by state attribute)
  def set_aasm_state_number
    self.aasm_state_number = AASM_STATE_NUMBER_MAP[self.aasm_state]
  end

  # Once the survey is finalized, we need to send the invitations.
  def send_invitations
    (invitations + external_invitations).each {|s|  s.send_invitation! }
  end
  
  # This adds the default questions.
  def add_default_questions
    DEFAULT_QUESTIONS.each do |pdq|
      pdq.build_questions(self) unless pdq.nil? # Don't blow up if we've changed PDQs...
    end
  end
  
  # If the user changed the number of days to run the survey, the end date needs to be updated
  def recalculate_end_date
    if !self.days_to_extend.blank? then
    
      self.end_date += self.days_to_extend.to_i.days if self.running?
      
      # if the survey was stalled, start from current time, as the survey may have been stalled for a while
      self.end_date = Time.now + self.days_to_extend.to_i.days if self.stalled?
      
      # make sure we clear this attr to ensure the survey is extended only once
      self.days_to_extend = nil
    end
  end
end
