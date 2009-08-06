class NetworkInvitation < Invitation
  belongs_to :network
  
  validates_presence_of :invitee
  validates_presence_of :network
  validate_on_create :not_already_invited_or_member
  
  after_create :send_invitation_email
  
  # accepts the invitation.
  def accept!
    invitee.networks << network
    destroy
  end
   
  private
  
  def not_already_invited_or_member
    if invitee && network then 
      not_already_invited 
      not_already_member 
    end
  end
  
  # adds an error if the invitee was already invited
  def not_already_invited
    errors.add_to_base "That organization is already invited to this network" if invitee.invited_networks.include?(network)
  end
  
  # adds an error if the invitee is already a member
  def not_already_member
    errors.add_to_base "That organization is already a member of this network" if invitee.networks.include?(network) || invitee.owned_networks.include?(network)
  end
 
  def send_invitation_email
    Notifier.deliver_network_invitation_notification(self)
  end
     
end
