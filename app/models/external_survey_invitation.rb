class ExternalSurveyInvitation < ExternalInvitation
  include AASM
  belongs_to :survey
  
  has_many :discussions, :as => :responder
  has_many :participations, :as => :participant
  has_many :responses, :through => :participations
  
  validates_presence_of :survey
  validates_presence_of :organization_name
  validate_on_create :not_already_invited

  attr_accessible :survey, :disccusions, :responses
  
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :sent
  
  aasm_event :send_invitation do
    transitions :to => :sent, :from => :pending, :on_transition => :send_invitation_email
  end
 
  private
  
  # adds an error if the email address was already invited
  def not_already_invited
    errors.add_to_base "That organization is already invited" if survey && survey.external_invitations.collect(&:email).include?(email)
  end  

  def send_invitation_email
    Notifier.deliver_external_survey_invitation_notification(self)
  end
end
