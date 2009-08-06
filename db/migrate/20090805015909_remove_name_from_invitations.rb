class RemoveNameFromInvitations < ActiveRecord::Migration
  def self.up
    remove_column :invitations, 'name'
  end

  def self.down
    add_column :invitations, 'name', :string, :limit => 100
  end
end
