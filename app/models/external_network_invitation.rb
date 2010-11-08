class ExternalNetworkInvitation < ExternalInvitation
  belongs_to :network  
  
  validates_presence_of :network
  validate_on_create :not_already_invited, :not_opted_out
  
  after_create :send_invitation_email
  
  # Accepts the invitation by making the invitee a network member and deleting the invitation
  def accept!(invitee)
    invitee.networks << network
    destroy
  end
   
  # Checks to make sure this email address hasn't opted out from our communications.
  def not_opted_out
    if !OptOut.find_by_email(self.email).nil?
      errors.add_to_base "We cannot send this invitation because #{self.email} has opted out of receiving email from CompSage."
    end
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
