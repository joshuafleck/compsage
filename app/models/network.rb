class Network < ActiveRecord::Base
  
  has_many :organizations, :through => :network_memberships
  has_many :network_memberships, :dependent => :destroy  
  belongs_to :owner, :class_name => "Organization"
  has_many :invitations, :class_name => 'NetworkInvitation', :dependent => :destroy
  has_many :external_invitations, :class_name => 'ExternalNetworkInvitation', :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :owner
  validates_length_of :name, :maximum => 128, :allow_blank => true
  validates_length_of :description, :allow_nil => true, :maximum => 1024
  
  after_create :set_owner_member
  
  # Promote the next most senior network member to be the new network owner. This is currently called from Organization
  # when the owner leaves a network, but can be used elsewhere.
  def promote_new_owner
    membership = self.network_memberships.find(
      :first, 
      :conditions => ["organization_id <> ?", self.owner.id], 
      :order => 'created_at')
    self.owner = membership.organization
    self.save
  end
  
  private
  
  #This will add the owner as a member of the network
  def set_owner_member
    self.organizations << self.owner
  end
  
end
