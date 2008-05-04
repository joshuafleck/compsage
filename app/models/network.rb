class Network < ActiveRecord::Base
  
  has_and_belongs_to_many :organizations, :join_table => "networks_organizations"
  belongs_to :owner, :class_name => "Organization"
  has_many :network_invitations, :dependent => :destroy
  has_many :external_network_invitations, :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :owner, :on => :create
  validates_length_of :name, :maximum => 128, :if => proc { |network| !network.name.blank? }
  validates_length_of :description, :allow_nil => true, :maximum => 1024
  
end
