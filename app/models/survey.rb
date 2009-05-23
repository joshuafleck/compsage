class Survey < ActiveRecord::Base
  include AASM

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
  has_many :discussions, :dependent => :destroy
  has_many :invitations, :class_name => 'SurveyInvitation', :dependent => :destroy
  has_many :external_invitations, :class_name => 'ExternalSurveyInvitation'
  has_many :internal_and_external_invitations, :class_name => 'Invitation'
  has_many :questions, :dependent => :destroy, :order => "position"
  has_many :responses, :through => :questions
  has_many :participations
  has_many :subscriptions, :class_name => 'SurveySubscription', :dependent => :destroy
  has_many :subscribed_organizations, :through => :survey_subscriptions, :source => :organization
    
  validates_presence_of :job_title
  validates_length_of :job_title, :maximum => 128
  validates_presence_of :days_running, :on => :create
  validates_presence_of :sponsor
  validate :questions_exist

  named_scope :since_last_week, Proc.new { {:conditions => ['end_date > ?', Time.now]} }
  named_scope :recent, :order => 'surveys.created_at DESC', :limit => 10
  named_scope :closed, :conditions => ['aasm_state = ? OR aasm_state = ?', 'finished', 'stalled']
  named_scope :not_finished, :conditions => "aasm_state <> 'finished'"
  named_scope :running_or_pending, :conditions => ['aasm_state = ? OR aasm_state = ?', 'running', 'pending']
  named_scope :running_or_stalled, :conditions => 'aasm_state = "running" OR aasm_state = "stalled"'
  named_scope :deletable, :conditions => ['aasm_state = ? OR aasm_state = ?', 'stalled', 'pending']
  
  accepts_nested_attributes_for :questions, :allow_destroy => true
  
  after_create :add_sponsor_subscription
  before_destroy :cancel_survey
  before_save :set_aasm_state_number
  
  ########### AASM Configuration: START ############
    
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :running
  aasm_state :stalled, :enter => :email_failed_message
  aasm_state :billing_error, :enter => :email_billing_error
  aasm_state :finished, :enter => :email_results_available
  
  # hack, for filtering surveys by aasm_state in sphinx
  AASM_STATE_NUMBER_MAP = {
    'pending' => 0,
    'running' => 1,
    'stalled' => 2,
    'billing_error' => 3,
    'finished' => 4
  }
  
  aasm_event :billing_info_received do
    transitions :to => :running, :from => :pending, :on_transition => :send_invitations_and_calculate_end_date_and_set_start_date
  end

  aasm_event :finish do
    # AASM currently doesn't support more than one guard, hence this absurd method here.
    transitions :to => :finished, :from => :running, :guard => :closed_and_full_report_and_billing_successful? 
    transitions :to => :billing_error, :from => :running, :guard => :closed_and_full_report?
    transitions :to => :stalled, :from => :running, :guard => :closed?
  end
  
  aasm_event :rerun do
    transitions :to => :running, :from => :stalled, :guard => :can_be_rerun?, :on_transition => :email_rerun_message_and_calculate_end_date
  end

  aasm_event :billing_error_resolved do
    transitions :to => :finished, :from => :billing
  end
  
  aasm_event :finish_with_partial_report do
    transitions :to => :finished, :from => :stalled, :guard => :closed_and_enough_responses_and_billing_successful? 
    transitions :to => :billing_error, :from => :stalled, :guard => :closed_and_enough_responses?
  end

  ############### AASM Configuration: END ###################
       
  # the minumum number of days a survey can be rerun
  MINIMUM_DAYS_TO_RERUN = 3
  # the maximum number of days a survey can be running for
  MAXIMUM_DAYS_TO_RUN = 21
  # the number of participations required to provide results for each question
  REQUIRED_NUMBER_OF_PARTICIPATIONS = 5

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

  # a survey can be rerun if there are enough days left to accomidate the minimum run length 
  # (and the survey is currently stalled)
  def can_be_rerun?
    days_until_rerun_deadline >= MINIMUM_DAYS_TO_RERUN && stalled?
  end
  
  # this will determine the maximum number of days the survey can be rerun for
  # 7 days if default, but it may be less if nearing the rerun deadline
  def maximum_days_to_rerun
    [days_until_rerun_deadline, 7].min
  end
  
  def rerun_deadline
    self.start_date + MAXIMUM_DAYS_TO_RUN.days
  end

  def days_until_rerun_deadline
    rerun_deadline.to_date - Date.today
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
    invitations = self.invitations.find(:all, :include => :invitee)
    invitations += self.external_invitations.find(:all)
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
  
  # find all predefined questions used in this survey
  def predefined_question_ids
    self.questions.collect(&:predefined_question_id)
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
    10000
  end
    
  private
    
  # TODO: Figure out who to email...
  def email_failed_message
    logger.info("Sending failed email message for survey #{self.id}")
    Notifier.deliver_survey_stalled_notification(self)
  end
  
  #method called for re-running a survey
  def email_rerun_message_and_calculate_end_date
    calculate_end_date
    email_rerun_message
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
  
  def send_invitations_and_calculate_end_date_and_set_start_date
    set_start_date
    calculate_end_date
    self.save # i noticed some trouble with sending invites without the save
    send_invitations
  end
    
  # returns whether or not there are enough responses and the survey is closed
  def closed_and_enough_responses?
    closed? && enough_responses?
  end  
 
  # returns whether or not there are enough responses and the survey is closed, and if so, if billing was successful
  def closed_and_enough_responses_and_billing_successful?
    closed_and_enough_responses? && billing_successful?
  end
  
  # returns whether or not all questions can be reported and the survey is closed
  def closed_and_full_report?
    closed? && full_report?
  end  
 
  # returns whether or not all questions can be reported and the survey is closed, and if so, if billing was successful
  def closed_and_full_report_and_billing_successful?
    closed_and_full_report? && billing_successful?
  end  

  # Calls the billing routine and returns whether or not billing was successful.
  def billing_successful?
    bill_sponsor
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
    self[:aasm_state_number] = AASM_STATE_NUMBER_MAP[self[:aasm_state]]
  end

  # Once the survey is finalized, we need to send the invitations.
  def send_invitations
    (invitations + external_invitations).each {|s|  s.send_invitation! }
  end
  
  # This will set the end date to the current date plus the number of days to run
  def calculate_end_date
    self[:end_date] = Time.now + days_running.to_i.days
  end
  
  # This will set the time the survey started running
  def set_start_date
    self[:start_date] = Time.now
  end

end
