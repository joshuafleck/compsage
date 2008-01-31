class CreateJoinTables < ActiveRecord::Migration
  def self.up
    create_table :organization_surveys do |t|
      t.column :organization_id, :integer
      t.column :survey_id,       :integer
    end
    
    create_table :network_organizations do |t|
      t.column :network_id,      :integer
      t.column :organization_id, :integer
    end
  end

  def self.down
    drop_table :organization_surveys
    drop_table :network_organizations
  end
end
