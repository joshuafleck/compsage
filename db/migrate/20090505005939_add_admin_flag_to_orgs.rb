class AddAdminFlagToOrgs < ActiveRecord::Migration
  def self.up
    add_column :organizations, :admin, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :organizations, :admin
  end
end
