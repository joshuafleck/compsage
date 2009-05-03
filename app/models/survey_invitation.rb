class SurveyInvitation < Invitation
  include AASM

  belongs_to :survey
  
  validates_presence_of :invitee
  validates_presence_of :survey
  validate_on_create :not_already_invited
  before_create :set_state
  
  named_scope :running, :include => :survey, :conditions => ["surveys.end_date > ?", Time.now ]
  
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :sent
  aasm_state :declined
  aasm_state :fulfilled
  
  aasm_event :send_invitation do
    transitions :to => :sent, :from => :pending, :on_transition => :send_invitation_email
  end

  aasm_event :decline do
    transitions :to => :declined, :from => :sent
  end  
  
  aasm_event :fulfill do
    transitions :to => :fulfilled, :from => :sent
  end    
  
  def to_s
    invitee.name_and_location
  end
  
  private
  
  # adds an error if the invitee was already invited (or the sponsor)
  def not_already_invited  
    errors.add_to_base "Invitee is already invited" if invitee && survey && (invitee.invited_surveys.include?(survey) || invitee == survey.sponsor)
  end

  def send_invitation_email
    Notifier.deliver_survey_invitation_notification(self)
  end
  
  # If the survey we're inviting to is pending, the invitation needs to be pending, otherwise it needs to be sent.
  def set_state
    if survey.running? then
      self.send_invitation
    end
  end
end
