class CreateAssociations < ActiveRecord::Migration
  def self.up
    create_table :associations do |t|
      t.string :name, :null => false, :default => ''
      t.string :subdomain, :limit => 20, :null => false, :default => ''
    end

    create_table :associations_organizations, :id => false do |t|
      t.references :association, :organization
    end

    add_index :associations_organizations, ['association_id', 'organization_id'], :unique => true,
      :name => 'habtm_index'
  end

  def self.down
    drop_table :associations_organizations
    drop_table :associations
  end
end
