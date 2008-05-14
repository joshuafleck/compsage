class Network < ActiveRecord::Base
  
  has_and_belongs_to_many :organizations
  belongs_to :owner, :class_name => "Organization"
  has_many :network_invitations, :dependent => :destroy
  has_many :external_network_invitations, :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :owner
  validates_length_of :name, :maximum => 128, :if => proc { |network| !network.name.blank? }
  validates_length_of :description, :allow_nil => true, :maximum => 1024
  
  after_create :set_owner_member
  
  #This will add the owner as a member of the network
  def set_owner_member
    self.organizations = [self.owner]
  end
  
  #If there are no members, destroy the network
  def destroy_when_empty
    self.destroy unless self.organizations.size > 0
  end
  
end
