class CreateJoinTables < ActiveRecord::Migration
  def self.up
    create_table :organizations_surveys do |t|
      t.column :organization_id, :integer
      t.column :survey_id,       :integer
    end
    
    add_index :organizations_surveys, :organization_id, :name => "index_organizations_surveys_on_organization_id"
    add_index :organizations_surveys, :survey_id, :name => "index_organizations_surveys_on_survey_id"
    
    create_table :networks_organizations do |t|
      t.column :network_id,      :integer
      t.column :organization_id, :integer
    end
    
    add_index :networks_organizations, :network_id, :name => "index_network_organizations_on_network_id"
    add_index :networks_organizations, :organization_id, :name => "index_network_organizations_on_organization_id"    
  end

  def self.down
    drop_table :organizations_surveys
    drop_table :networks_organizations
  end
end
