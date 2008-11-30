class SurveyInvitation < Invitation
  include AASM

  belongs_to :survey
  
  validates_presence_of :invitee
  validates_presence_of :survey
  
  named_scope :running, :include => :survey, :conditions => ["surveys.end_date > ?", Time.now ]
  named_scope :pending, :conditions => ['invitations.aasm_state = ?', 'pending']
  
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :declined
  aasm_state :fufilled
  
  aasm_event :decline do
    transitions :to => :declined, :from => :pending
  end  
  
  aasm_event :fufill do
    transitions :to => :fufilled, :from => :pending
  end    
  
end
