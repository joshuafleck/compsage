class SurveyInvitation < Invitation
  belongs_to :survey
  belongs_to :invitee, :class_name => "Organization", :foreign_key => "invitee_id"
  belongs_to :invitor, :class_name => "Organization", :foreign_key => "invitor_id" 
end
