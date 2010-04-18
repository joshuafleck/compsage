class RemoveIsPrefix < ActiveRecord::Migration
  def self.up
    rename_column :organizations, :is_pending, :pending
    rename_column :organizations, :is_uninitialized_association_member, :uninitialized_association_member
  end

  def self.down
    rename_column :organizations, :uninitialized_association_member, :is_uninitialized_association_member
    rename_column :organizations, :pending, :is_pending
  end
end
