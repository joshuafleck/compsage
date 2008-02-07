class CreateJoinTables < ActiveRecord::Migration
  def self.up
    create_table :organizations_surveys do |t|
      t.column :organization_id, :integer
      t.column :survey_id,       :integer
    end
    
    create_table :networks_organizations do |t|
      t.column :network_id,      :integer
      t.column :organization_id, :integer
    end
  end

  def self.down
    drop_table :organizations_surveys
    drop_table :networks_organizations
  end
end
