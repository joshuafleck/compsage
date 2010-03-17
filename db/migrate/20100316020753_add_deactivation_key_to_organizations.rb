class AddDeactivationKeyToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, 'deactivation_key', :string
    add_column :organizations, 'deactivated_at', :datetime
    add_index  :organizations, :deactivation_key    
  end

  def self.down
    remove_column :organizations, 'deactivation_key'
    remove_column :organizations, 'deactivated_at'
  end
end
