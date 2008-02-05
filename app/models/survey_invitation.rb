class SurveyInvitation < Invitation
  belongs_to :survey
  belongs_to :organization, :foreign_key => "invitee_id"
  belongs_to :organization, :foreign_key => "invitor_id"  
end
