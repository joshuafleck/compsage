class ExternalNetworkInvitation < ExternalInvitation
  belongs_to :network  
  
  validates_presence_of :network
  validate_on_create :not_already_invited
  
  after_create :send_invitation_email
  
  # Accepts the invitation by making the invitee a network member and deleting the invitation
  def accept!(invitee)
    invitee.networks << network
    destroy
  end
   
  private
  
  # Adds an error if the invitee is already invited
  def not_already_invited
    errors.add_to_base "That organization is already invited" if network && network.external_invitations.collect(&:email).include?(email)
  end  
  
  def send_invitation_email
    Notifier.deliver_external_network_invitation_notification(self)
  end
  
end
