class NetworkInvitation < Invitation
  belongs_to :network
  
  validates_presence_of :invitee
  validates_presence_of :network
  
  # accepts the invitation.
  def accept!
    invitee.networks << network
    destroy
  end
end
