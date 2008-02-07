class NetworkInvitation < Invitation
  belongs_to :network
  belongs_to :invitee, :class_name => "Organization", :foreign_key => "invitee_id"
  belongs_to :invitor, :class_name => "Organization", :foreign_key => "invitor_id"  
end
