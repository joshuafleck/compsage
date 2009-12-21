class AddPendingReportedActivationKeyToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, 'is_pending', :boolean, :default => false
    add_column :organizations, 'times_reported', :integer, :default => 0
    add_column :organizations, 'activation_key', :string
    add_column :organizations, 'activation_key_created_at', :datetime
    add_column :organizations, 'activated_at', :datetime
    add_index  :organizations, :activation_key
    
    Organization.reset_column_information
    Organization.find(:all).each do |o|
      o.update_attribute :activated_at, o.created_at
    end    
    
  end

  def self.down
    remove_column :organizations, 'is_pending'
    remove_column :organizations, 'times_reported'
    remove_column :organizations, 'activation_key'
    remove_column :organizations, 'activation_key_created_at'
    remove_column :organizations, 'activated_at'
  end
end
