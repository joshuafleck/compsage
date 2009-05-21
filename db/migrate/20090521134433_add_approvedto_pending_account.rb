class AddApprovedtoPendingAccount < ActiveRecord::Migration
  def self.up
    add_column :pending_accounts, :approved, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :pending_accounts, :approved
  end
end
