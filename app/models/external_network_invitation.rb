class ExternalNetworkInvitation < ExternalInvitation

  belongs_to :network  
  
  validates_presence_of :network
  
  attr_accessible :network
end
