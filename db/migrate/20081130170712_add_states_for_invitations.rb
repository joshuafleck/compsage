class AddStatesForInvitations < ActiveRecord::Migration
  def self.up
    add_column :invitations, 'aasm_state', :string, :limit => 30
    add_index :invitations, 'aasm_state'
  end

  def self.down
    remove_column :invitations, 'state'
  end
end
