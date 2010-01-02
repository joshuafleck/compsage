class Survey < ActiveRecord::Base

  belongs_to :sponsor, :class_name => "Organization"
  has_one  :invoice, :dependent => :destroy
  has_many :discussions, :dependent => :destroy
  has_many :invitations, :class_name => 'SurveyInvitation'
  has_many :invitees, :class_name => 'Organization', :through => :invitations
  has_many :external_invitations, :class_name => 'ExternalSurveyInvitation'
  has_many :internal_and_external_invitations, :class_name => 'Invitation', :order => "created_at"
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
  validates_length_of :job_title, :maximum => 128, :on => :update, :allow_blank => true
  validates_presence_of :days_running, :on => :update
  validates_presence_of :sponsor
  validate_on_update :questions_exist

  named_scope :recent, :order => 'surveys.created_at DESC', :limit => 10
  named_scope :most_recent,  # used by the Invoice initializer
    :order => 'end_date DESC', 
    :conditions => 'end_date IS NOT NULL', 
    :limit => 1
    
  after_create :add_sponsor_subscription, :add_default_questions, :invite_sponsor
  before_destroy :cancel_survey
  before_save :set_aasm_state_number, :recalculate_end_date
  
  # The number of days to extend the survey deadline.
  # Used for recalculating the end date.
  attr_accessor :days_to_extend
   
  ########### Sphinx Configuration: START ############
  
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
    
    # This will cause any changes to surveys between index rebuilds to be stored in a delta index until the next rebuild.
    set_property :delta => true
  end  
  
  ########### Sphinx Configuration: END ############   

  ########### State Machine Configuration: START ############
    
  state_machine 'aasm_state', :initial => :pending do
    after_transition :pending => :running,  :do => [:set_start_and_end_dates, :send_invitations]
    after_transition :stalled => :running,  :do => :email_rerun_message
    after_transition any => :stalled,       :do => :email_failed_message
    after_transition any => :billing_error, :do => :email_billing_error 
    after_transition any => :finished,      :do => [:email_results_available, :email_receipt]

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
      transition :stalled => :finished,      :if => [:closed?, :enough_responses?, :billing_successful?]
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

  ############### State Machine Configuration: END ###################
       
  # the minumum number of days a survey can be extended
  MINIMUM_DAYS_TO_EXTEND = 3
  # the maximum number of days a survey can be running for
  MAXIMUM_DAYS_TO_RUN = 21
  # the number of participations required to provide results for each question
  REQUIRED_NUMBER_OF_PARTICIPATIONS = 5
  # the minumum number of invitations required to create a survey
  REQUIRED_NUMBER_OF_INVITATIONS = REQUIRED_NUMBER_OF_PARTICIPATIONS
  # the price of a surevy in cents
  PRICE = 9900

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
  
  # Retrieve the number of days to run the survey, 7 is the default.
  def days_running
    self[:days_running] || 7
  end

  # A survey can be rerun if there are enough days left to accomodate the minimum run length 
  # (and the survey is currently stalled)
  def can_be_rerun?
    can_be_extended? && stalled?
  end
  
  # Determines if there are enough days left to accomodate the minimum run length.
  def can_be_extended?
    days_until_extension_deadline >= MINIMUM_DAYS_TO_EXTEND
  end
  
  # This will determine the maximum number of days for which the survey can be extended.
  # 7 days is default, but it may be less if nearing the extension deadline.
  def maximum_days_to_extend
    [days_until_extension_deadline, 7].min
  end
  
  # The date at which the survey must cease running.
  def extension_deadline
    self.start_date + MAXIMUM_DAYS_TO_RUN.days
  end

  # The number of days the survey can be extended.
  # If the survey is running, base this off of the end date.
  # If the survey is stalled, base this off of the current date (the end date may be many days past).
  def days_until_extension_deadline
    extension_deadline.to_date - (self.running? ? self.end_date.to_date : Date.today)
  end

  # The date that the survey began running. It may not be set, so use the current time as a substitute.
  def start_date
    self[:start_date] || Time.now
  end
  
  # All data should be reported as of this date
  def effective_date
    (self.start_date - 90.days).to_date
  end
 
  # True, if the survey has the required number of participations.
  def enough_participations?
    participations.count >= REQUIRED_NUMBER_OF_PARTICIPATIONS
  end
  
  # True, if the survey has enough participations and at least one reportable question.
  def enough_responses?
    self.enough_participations? && !self.no_reportable_questions?
  end
  
  # True, if the survey has at least as many invitations as the required number of participations
  def enough_invitations_to_create?
    self.internal_and_external_invitations.count < REQUIRED_NUMBER_OF_INVITATIONS
  end
  
  # True, if all questions can be reported.
  def full_report?
    self.questions.each do |question|
      return false unless question.adequate_responses?
    end
    
    return true
  end
  
  # True, if no questions can be reported.
  def no_reportable_questions?
    !self.questions.any?(&:adequate_responses?) 
  end
  
  # Retrieves all of the questions that can be reported.
  def reportable_questions
    self.questions.find_all{|q| q.adequate_responses?}
  end

  def to_s
    job_title
  end
   
  # Same price for all surveys for now.  This is in cents.
  def price
    PRICE
  end  
  
  private
  
  ############### Methods for sending emails: START ###################  
    
  # Informs the sponsor that the survey is stalled.
  def email_failed_message
    Notifier.deliver_survey_stalled_notification(self)
  end
  
  # Email all participants so they know they may be receiving results.
  # Email all invitees that have yet to respond so they know there is more time.
  def email_rerun_message   
    self.participations.each do |p| 
      Notifier.deliver_survey_rerun_notification_participant(self,p.participant) unless p.participant == self.sponsor
    end 
    self.internal_and_external_invitations.sent.each do |i| 
      invitee = (i.is_a? ExternalSurveyInvitation) ? i : i.invitee
      Notifier.deliver_survey_rerun_notification_non_participant(self,invitee)
    end
  end
  
  # Send email informing respondants that the results are available.
  def email_results_available
    participants = participations.collect { |p| p.participant } 
    # because has_many :through doesn't work backwards w/ polymorphism :/
    
    participants.each do |participant|
      Notifier.deliver_survey_results_available_notification(self, participant)
    end

    # the sponsor may not have participated, so do a special check for him
    Notifier.deliver_survey_results_available_notification(self, sponsor) unless participants.include?(sponsor)
  end

  # Notify the participants that the sponsor is not rerunning the survey.
  def email_not_rerunning_message
    participations.collect(&:participant).each do |participant|
      Notifier.deliver_survey_not_rerunning_notification(self, participant)
    end
  end
 
  # Notifies the sponsor that there was a problem with billing.
  def email_billing_error
    # TODO: Implement
  end
  
  # This will either email the credit card receipt, or the invoice to the sponsor
  def email_receipt
    if self.invoice.paying_with_credit_card? then
      # TODO: implement
    else
      Notifier.deliver_invoice(self)
    end
  end
  
  ############### Methods for sending emails: END ###################
    
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
  
  # Once the survey goes into running mode, the start/end dates must be set
  def set_start_and_end_dates 
    self.start_date = Time.now
    self.end_date = self.start_date + days_running.to_i.days
    self.save # I noticed some trouble with sending invites without the save
  end
    
  # Calls the billing routine and returns whether or not billing was successful.
  def billing_successful?
    if self.invoice.paying_with_credit_card? then
      # If we are paying by credit card, bill the card
      bill_sponsor
    else
      # If paying by invoice, the sponsor will mail their payment
      return true
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
    self.internal_and_external_invitations.pending.each {|s|  s.send_invitation! }
  end
  
  # This adds the default questions.
  def add_default_questions
    DEFAULT_QUESTIONS.each do |pdq|
      pdq.build_questions(self) unless pdq.nil? # Don't blow up if we've changed PDQs...
    end
  end
  
  # Creates an invitation for the survey sponsor. This invitation has only one state, since we do not need to 
  # present the invitation to the sponsor.
  def invite_sponsor
    invitation = self.invitations.new(
      :survey  => self, 
      :inviter => self.sponsor, 
      :invitee => self.sponsor,
      :aasm_state => 'fulfilled')
    invitation.save!
  end
  
  # If the user changed the number of days to run the survey, the end date needs to be updated
  def recalculate_end_date
    if !self.days_to_extend.blank? then
    
      # If the survey is running, start extending from the end date
      self.end_date += self.days_to_extend.to_i.days if self.running?
      
      # If the survey is stalled, start extending from current time, as the survey may have been stalled for a while
      self.end_date = Time.now + self.days_to_extend.to_i.days if self.stalled?
      
      # Make sure we clear this attribute to ensure the survey is extended only once
      self.days_to_extend = nil
    end
  end
end
