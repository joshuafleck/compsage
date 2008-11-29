class Survey < ActiveRecord::Base
  include AASM

  define_index do
    indexes job_title
    indexes description
    indexes sponsor.industry, :as => :industry
    
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
  has_many :external_invitations, :class_name => 'ExternalSurveyInvitation', :dependent => :destroy
  has_many :questions
  has_many :responses, :through => :questions
  has_many :participations
  has_many :subscriptions, :class_name => 'SurveySubscription', :dependent => :destroy
  has_many :subscribed_organizations, :through => :survey_subscriptions, :source => :organization
  
  validates_presence_of :job_title
  validates_length_of :job_title, :maximum => 128
  validates_presence_of :end_date, :on => :create
  validates_presence_of :sponsor
  
  named_scope :since_last_week, Proc.new { {:conditions => ['end_date > ?', Time.now]} }
  named_scope :recent, :order => 'surveys.created_at DESC', :limit => 10
  named_scope :closed, :conditions => ['aasm_state = ? OR aasm_state = ?', 'finished', 'stalled']
  
  after_create :add_sponsor_subscription
  
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :running
  aasm_state :stalled, :enter => :email_failed_message
  aasm_state :billing_error, :enter => :email_billing_error
  aasm_state :finished, :enter => :email_results_available
  
  aasm_event :billing_info_received do
    transitions :to => :running, :from => :pending
  end

  aasm_event :finish do
    # AASM currently doesn't support more than one guard, hence this absurd method here.
    transitions :to => :finished, :from => :running, :guard => :enough_responses_and_billing_successful? 
    transitions :to => :billing_error, :from => :running, :guard => :enough_responses?
    transitions :to => :stalled, :from => :running
  end
  
  aasm_event :rerun do
    #TODO: send a notification to invitees that survey is being rerun
    transitions :to => :running, :from => :stalled, :guard => :open?
  end

  aasm_event :billing_error_resolved do
    transitions :to => :finished, :from => :billing
  end
  

  def days_running
    @days_running
  end
  
  def days_running=(days)
    @days_running = days
    self[:end_date] = Time.now.at_beginning_of_day + days.to_i.days
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
  
  def required_number_of_participations
    5
  end
  
  def to_s
    job_title
  end
  
  # Same price for all surveys for now.  This is in cents.
  def price
    10000
  end

  private
  
  def enough_responses?
    participations.count >= required_number_of_participations
  end
  
  # TODO: Figure out who to email...
  def email_failed_message
    logger.info("Sending failed email message for survey #{self.id}")
    Notifier.deliver_survey_stalled_notification(self)
  end
  
  # Send email informing respondants that the results are available.
  def email_results_available
    participants = participations.collect { |p| p.participant } # because has_many :through doesn't work backwards w/ polymorphism :/
    
    participants.each do |participant|
      Notifier.deliver_survey_results_available_notification(self, participant)
    end

    Notifier.deliver_survey_results_available_notification(self, sponsor) unless participants.include?(sponsor)
  end
  
  def email_billing_error
    # TODO: Implement
  end
  
  # Creates a survey subscription for the survey sponsor.
  def add_sponsor_subscription
    s = subscriptions.create!(:organization => sponsor, :relationship => 'sponsor')
  end
 
  # returns whether or not there are enough responses, and if so, if billing was successful
  def enough_responses_and_billing_successful?
    enough_responses? && billing_successful?
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

end
