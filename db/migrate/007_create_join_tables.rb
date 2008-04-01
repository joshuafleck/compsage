class CreateJoinTables < ActiveRecord::Migration
	def self.up
    create_table :networks_organizations do |t|
      t.column :network_id,      :integer
      t.column :organization_id, :integer
    end
    
    add_index :networks_organizations, :network_id
    add_index :networks_organizations, :organization_id
  end

  def self.down
    drop_table :networks_organizations
  end
end
