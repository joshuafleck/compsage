class NetworkInvitation < Invitation

  belongs_to :network  
  
  validates_presence_of :network
  
end
