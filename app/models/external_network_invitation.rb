class ExternalNetworkInvitation < ExternalInvitation

  belongs_to :network  
  
  validates_presence_of :network
  
end
