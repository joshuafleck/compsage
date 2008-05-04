class NoIdInNetworksOrganizations < ActiveRecord::Migration
  def self.up
    remove_column :networks_organizations, 'id'
  end

  def self.down
    add_column :networks_organizations, 'id', :integer
  end
end
