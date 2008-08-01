class Survey < ActiveRecord::Base

  include AASM

  define_index do
    indexes job_title
    indexes description
  end

  belongs_to :sponsor, :class_name => "Organization"
  has_many :discussions, :dependent => :destroy
  has_many :invitations, :class_name => 'SurveyInvitation', :dependent => :destroy
  has_many :external_invitations, :class_name => 'ExternalSurveyInvitation', :dependent => :destroy
  has_many :questions
  has_many :responses, :through => :questions
  has_many :participations
  
  validates_presence_of :job_title
  validates_length_of :job_title, :maximum => 128
  validates_presence_of :end_date, :on => :create
  validates_presence_of :sponsor
  
  named_scope :recent, :order => 'created_at DESC', :limit => 10
  
  
  aasm_initial_state :running
  
  aasm_state :running
  aasm_state :stalled, :enter => :email_failed_message
  aasm_state :finished, :enter => :email_results_available
  
  aasm_event :finish do
    transitions :to => :finished, :from => :running, :guard => :enough_responses?
    transitions :to => :stalled, :from => :running
  end
  
  aasm_event :rerun do
    transitions :to => :running, :from => :stalled
  end
  
  def closed?
    Time.now > end_date
  end
  
  def open?
    !closed?
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
end
