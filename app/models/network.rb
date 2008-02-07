class Network < ActiveRecord::Base
  
  has_and_belongs_to_many :organizations, :join_table => "networks_organizations"
  belongs_to :owner, :class_name => "Organization"


end
