class AddUninitializedAssociationMemberFlagToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :is_uninitialized_association_member, :boolean, :default => 0
    Organization.reset_column_information
    Organization.find(:all).each do |o|
      o.update_attribute :is_uninitialized_association_member, false
    end
  end

  def self.down
    remove_column :organizations, :is_uninitialized_association_member
  end
end
