class Survey < ActiveRecord::Base
  include AASM

  define_index do
    indexes job_title
    indexes description
    indexes sponsor.industry, :as => :industry
    indexes aasm_state
    
    has subscriptions.organization_id, :as => :subscribed_by
    has sponsor.latitude, :as => :latitude, :type => :float
    has sponsor.longitude, :as => :longitude, :type => :float

    set_property :latitude_attr   => "latitude"
    set_property :longitude_attr  => "longitude"
    
    # this will cause any changes to surveys between index rebuilds to be stored in a delta index until the next rebuild
    set_property :delta => true
  end

  belongs_to :sponsor, :class_name => "Organization"
  has_many :discussions, :dependent => :destroy
  has_many :invitations, :class_name => 'SurveyInvitation', :dependent => :destroy
  has_many :external_invitations, :class_name => 'ExternalSurveyInvitation'
  has_many :questions, :dependent => :destroy
  has_many :responses, :through => :questions
  has_many :participations
  has_many :subscriptions, :class_name => 'SurveySubscription', :dependent => :destroy
  has_many :subscribed_organizations, :through => :survey_subscriptions, :source => :organization
  
  attr_accessor :network_id
  
  validates_presence_of :job_title
  validates_length_of :job_title, :maximum => 128
  validates_presence_of :end_date, :on => :create
  validates_presence_of :sponsor
  validate :questions_exist

  named_scope :since_last_week, Proc.new { {:conditions => ['end_date > ?', Time.now]} }
  named_scope :recent, :order => 'surveys.created_at DESC', :limit => 10
  named_scope :closed, :conditions => ['aasm_state = ? OR aasm_state = ?', 'finished', 'stalled']
  named_scope :not_finished, :conditions => "aasm_state <> 'finished'"
  
  after_create :add_sponsor_subscription
  before_destroy :cancel_survey
    
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :running
  aasm_state :stalled, :enter => :email_failed_message, :exit => :email_rerun_message
  aasm_state :billing_error, :enter => :email_billing_error
  aasm_state :finished, :enter => :email_results_available
  
  aasm_event :billing_info_received do
    transitions :to => :running, :from => :pending
  end

  aasm_event :finish do
    # AASM currently doesn't support more than one guard, hence this absurd method here.
    transitions :to => :finished, :from => :running, :guard => :closed_and_enough_responses_and_billing_successful? 
    transitions :to => :billing_error, :from => :running, :guard => :closed_and_enough_responses?
    transitions :to => :stalled, :from => :running, :guard => :closed?
  end
  
  aasm_event :rerun do
    transitions :to => :running, :from => :stalled, :guard => :open_and_can_be_rerun?
  end

  aasm_event :billing_error_resolved do
    transitions :to => :finished, :from => :billing
  end
   
  # the minumum number of days a survey can be rerun
  MINIMUM_DAYS_TO_RERUN = 3
  # the maximum number of days a survey can be running for
  MAXIMUM_DAYS_TO_RUN = 21
  # the number of participations required to provide results for each question
  REQUIRED_NUMBER_OF_PARTICIPATIONS = 5

  def days_running
    @days_running
  end
  
  def days_running=(days)
    @days_running = days
    self[:end_date] = Time.now + days.to_i.days
  end
  
  def closed?
    Time.now > end_date
  end
  
  def open?
    !closed?
  end
  
  # returns a sorted list of all (survey and external_survey) invitations
  def all_invitations(include_sponsor = false)
    invitations = self.invitations.find(:all, :include => :invitee)
    invitations += self.external_invitations.find(:all)
    invitations << SurveyInvitation.new(:invitee => self.sponsor) if include_sponsor
    invitations.sort    
  end
  
  # a survey can be rerun if there are enough days left to accomidate the minimum run
  # length
  def can_be_rerun?
    days_until_rerun_deadline >= MINIMUM_DAYS_TO_RERUN && stalled? 
  end
  
  # this will determine the maximum number of days the survey can be rerun for
  # 7 days if default, but it may be less if nearing the rerun deadline
  def maximum_days_to_rerun
    [days_until_rerun_deadline, 7].min
  end
  
  def rerun_deadline
    self.created_at + MAXIMUM_DAYS_TO_RUN.days
  end

  def days_until_rerun_deadline
    rerun_deadline.to_date - Date.today
  end

  def to_s
    job_title
  end
  
  # Same price for all surveys for now.  This is in cents.
  def price
    10000
  end

  # determine if the survey had adequate invitations for providing results
  def enough_invitations?
    [self.all_invitations(true).size,self.participations.size].max >= REQUIRED_NUMBER_OF_PARTICIPATIONS
  end
  
  # determine the recommended number of invitations necessary to provide results
  def recommended_number_of_invitations
    REQUIRED_NUMBER_OF_PARTICIPATIONS - [self.all_invitations(true).size,self.participations.size].max
  end
  
  # this will invite the speicified network to the survey
  def invite_network    
    self.sponsor.networks.find(self.network_id).organizations.each do |organization|
      self.invitations.create(
        :invitee => organization, 
        :inviter => self.sponsor) unless organization == self.sponsor
    end unless self.network_id.blank?
  end
  
  # find all predefined questions, mark any questions this survey uses as 'included'
  def predefined_questions
    all_predefined = PredefinedQuestion.all
    selected_predefined = self.questions.collect(&:predefined_question_id)
    all_predefined.each do |predefined_question|
      predefined_question.included = selected_predefined.include?(predefined_question.id) ? "1" : "0"
    end
    all_predefined
  end
  
  # find all custom questions, mark all as 'included'
  def custom_questions
    self.questions.find_all{|q| !q.custom_question_type.blank?}.each{|q| q.included = "1"}
  end
  
  private
  
  def enough_responses?
    participations.count >= REQUIRED_NUMBER_OF_PARTICIPATIONS
  end
  
  # TODO: Figure out who to email...
  def email_failed_message
    logger.info("Sending failed email message for survey #{self.id}")
    Notifier.deliver_survey_stalled_notification(self)
  end
  
  def email_rerun_message
    #email all participants (so they know they may be receiving results), all pending invitees, external invitees
    distribution_list = participations.collect { |p| p.participant } + 
      invitations.pending.collect { |p| p.invitee } + 
      external_invitations
    distribution_list.uniq.each do |notify|
      Notifier.deliver_survey_rerun_notification(self,notify)
    end
  end
  
  # Send email informing respondants that the results are available.
  def email_results_available
    participants = participations.collect { |p| p.participant } # because has_many :through doesn't work backwards w/ polymorphism :/
    
    participants.each do |participant|
      Notifier.deliver_survey_results_available_notification(self, participant)
    end

    Notifier.deliver_survey_results_available_notification(self, sponsor) unless participants.include?(sponsor)
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

  # notify the participants that the sponsor is not rerunning the survey
  def email_not_rerunning_message
    participations.collect(&:participant).each do |participant|
      Notifier.deliver_survey_not_rerunning_notification(self, participant)
    end
  end
  
  def email_billing_error
    # TODO: Implement
  end
  
  # Creates a survey subscription for the survey sponsor.
  def add_sponsor_subscription
    s = subscriptions.create!(:organization => sponsor, :relationship => 'sponsor')
  end
  
  # returns whether or not there are enough responses and the survey is closed
  def closed_and_enough_responses?
    closed? && enough_responses?
  end  
 
  # returns whether or not there are enough responses and the survey is closed, and if so, if billing was successful
  def closed_and_enough_responses_and_billing_successful?
    closed_and_enough_responses? && billing_successful?
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
  
  # determine whether the survey is open, and can be rerun
  def open_and_can_be_rerun?
    self.open? && self.can_be_rerun?
  end

  private
  
  # Validates whether or not questions have been chosen.
  def questions_exist
    errors.add_to_base("You must choose at least one question to ask") if questions.empty?
  end

end
