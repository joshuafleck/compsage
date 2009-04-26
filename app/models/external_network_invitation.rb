class ExternalNetworkInvitation < ExternalInvitation

  belongs_to :network  
  
  validates_presence_of :network
  validate_on_create :not_already_invited
  
  attr_accessible :network
   
  private
  
  # adds an error if the invitee is already invited
  def not_already_invited
    errors.add_to_base "Invitee is already invited" if network && network.external_invitations.collect(&:email).include?(email)
  end  
end
