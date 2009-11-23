class AddAssociationMemberInitializationKeyToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, 'association_member_initialization_key', :string, :limit => 40
    add_column :organizations, 'association_member_initialization_key_created_at', :datetime
  end

  def self.down
    remove_column :organizations, 'association_member_initialization_key'
    remove_column :organizations, 'association_member_initialization_key_created_at'
  end
end
