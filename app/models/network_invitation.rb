class NetworkInvitation < Invitation
  belongs_to :network
  
  validates_presence_of :invitee
  validates_presence_of :network
  
  # accepts the invitation.
  def accept!
    invitee.networks << network
    destroy
  end
   
  def validate_on_create
    if invitee && network then 
      validate_not_invited 
      validate_not_member 
    end
  end  
  
  def to_s
    invitee.name_and_location
  end
  
  private
  
  def validate_not_invited
    errors.add_to_base "Invitee is already invited" if invitee.invited_networks.include?(network)
  end
  
  def validate_not_member
    errors.add_to_base "Invitee is already a member" if invitee.networks.include?(network) || invitee.owned_networks.include?(network)
  end
   
end
