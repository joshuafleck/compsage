class AddOrganizationNameToExternalInvitation < ActiveRecord::Migration
  def self.up
    add_column :invitations, 'organization_name', :string, :limit => 100
  end

  def self.down
    remove_column :invitations, 'organization_name'
  end
end
