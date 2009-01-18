class NetworkMemberships < ActiveRecord::Migration
  def self.up
    create_table :network_memberships do |t|
      t.column :network_id,      :integer,  :null => false
      t.column :organization_id, :integer,  :null => false
      t.column :created_at,      :datetime, :null => false
    end
    
    add_index :network_memberships, :network_id
    add_index :network_memberships, :organization_id
    
    drop_table :networks_organizations
  end

  def self.down
    drop_table :network_memberships
       
    create_table :networks_organizations do |t|
      t.column :network_id,      :integer
      t.column :organization_id, :integer
    end
    
    add_index :networks_organizations, :network_id
    add_index :networks_organizations, :organization_id
  end
end
