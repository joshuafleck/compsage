class NetworkInvitation < Invitation
  belongs_to :network
  belongs_to :organization, :foreign_key => "invitee_id"
  belongs_to :organization, :foreign_key => "invitor_id"  
end
