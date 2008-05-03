class NetworkInvitation < Invitation
  belongs_to :network
  
  validates_presence_of :invitee
  validates_presence_of :network
  
  # accepts the invitation.  Currently not in use, examining performance implications.
  def accept!
    invitee.networks << network
    destroy
  end
end
