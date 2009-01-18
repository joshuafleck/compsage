class Network < ActiveRecord::Base
  
  has_many :organizations, :through => :network_memberships
  has_many :network_memberships, :dependent => :destroy  
  belongs_to :owner, :class_name => "Organization"
  has_many :invitations, :class_name => 'NetworkInvitation', :dependent => :destroy
  has_many :external_invitations, :class_name => 'ExternalNetworkInvitation', :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :owner
  validates_length_of :name, :maximum => 128, :if => proc { |network| !network.name.blank? }
  validates_length_of :description, :allow_nil => true, :maximum => 1024
  
  after_create :set_owner_member
  
  attr_accessor :included
  
  # returns a sorted list of all (network and external_network) invitations
  def all_invitations(include_owner = false)
    invitations = self.invitations.find(:all, :include => :invitee)
    invitations += self.external_invitations.find(:all)
    invitations << NetworkInvitation.new(:invitee => self.owner) if include_owner
    invitations.sort    
  end
  
  # if the owner leaves the network, they will be replaced with the next senior member
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
    self.organizations = [self.owner]
  end
  
end
