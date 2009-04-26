class SurveyInvitation < Invitation
  include AASM

  belongs_to :survey
  
  validates_presence_of :invitee
  validates_presence_of :survey
  validate_on_create :not_already_invited
  
  named_scope :running, :include => :survey, :conditions => ["surveys.end_date > ?", Time.now ]
  
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :declined
  aasm_state :fulfilled
  
  aasm_event :decline do
    transitions :to => :declined, :from => :pending
  end  
  
  aasm_event :fulfill do
    transitions :to => :fulfilled, :from => :pending
  end    
  
  def to_s
    invitee.name_and_location
  end
  
  private
  
  # adds an error if the invitee was already invited (or the sponsor)
  def not_already_invited  
    errors.add_to_base "Invitee is already invited" if invitee && survey && (invitee.invited_surveys.include?(survey) || invitee == survey.sponsor)
  end
end
