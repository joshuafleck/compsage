class Network < ActiveRecord::Base
  
  has_and_belongs_to_many :organizations, :join_table => "network_organizations"
  belongs_to :organization, :foreign_key => "organization_id"
  
end
