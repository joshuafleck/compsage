class ExternalNetworkInvitation < ExternalInvitation

  belongs_to :network  
  
  validates_presence_of :network
  
  attr_accessible :network
   
  def validate_on_create
    validate_not_invited if network
  end
  
  private
  
  def validate_not_invited
    errors.add_to_base "Invitee is already invited" if network.external_invitations.collect(&:email).include?(email)
  end  
end
