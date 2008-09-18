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
    
    # because we are adding the industry to the query itself, we need to 
    # weight the other fields to ensure relevant matches still float to the top
    set_property :field_weights => {"job_title" => 6, "description" => 4, "@geodist" => 2}
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
  
  named_scope :recent, :order => 'surveys.created_at DESC', :limit => 10
  
  after_create :add_sponsor_subscription
  
  aasm_initial_state :running
  
  aasm_state :running
  aasm_state :stalled, :enter => :email_failed_message
  aasm_state :finished, :enter => :email_results_available
  
  aasm_event :finish do
    transitions :to => :finished, :from => :running, :guard => :enough_responses?
    transitions :to => :stalled, :from => :running
  end
  
  aasm_event :rerun do
    #TODO: send a notification to invitees that survey is being rerun
    transitions :to => :running, :from => :stalled, :guard => :open?
  end
  
  def days_running
    @days_running
  end
  
  def days_running=(days)
    @days_running = days
    self[:end_date] = Time.now.at_beginning_of_day + days.to_i.days
    p end_date
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
  
  private
  
  def enough_responses?
    participations.count >= 5
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
  
  # Creates a survey subscription for the survey sponsor.
  def add_sponsor_subscription
    s = subscriptions.create!(:organization => sponsor, :relationship => 'sponsor')
  end
    
end
