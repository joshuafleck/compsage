class AddAssociationBillingStatus < ActiveRecord::Migration
  def self.up
    add_column :surveys, 'association_billing_status', :string, :limit => 50, :null => false, :default => 'Not Billed'
    add_index :surveys, 'association_billing_status'
  end

  def self.down
    remove_column :surveys, 'association_billing_status'
  end
end
