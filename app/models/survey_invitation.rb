class SurveyInvitation < Invitation
  belongs_to :survey
  
  validates_presence_of :invitee
  validates_presence_of :survey
  validate_on_create :not_already_invited
  
  named_scope :running, :include => :survey, :conditions => ["surveys.aasm_state = ?", 'running']

  state_machine 'aasm_state', :initial => :pending do
    after_transition :pending => :sent, :do => :send_invitation_email

    event :send_invitation do
      transition :pending => :sent
    end

    event :decline do
      transition :sent => :declined
    end

    event :fulfill do
      transition :sent => :fulfilled
    end
  end
  
  private
  
  # adds an error if the invitee was already invited (or the sponsor)
  def not_already_invited  
    errors.add_to_base "That organization is already invited" if invitee && survey && (invitee.invited_surveys.include?(survey) || invitee == survey.sponsor)
  end

  def send_invitation_email
    Notifier.deliver_survey_invitation_notification(self)
  end
 end
