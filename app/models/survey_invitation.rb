class SurveyInvitation < Invitation

  belongs_to :survey
  
  validates_presence_of :invitee
  validates_presence_of :survey
  
end
