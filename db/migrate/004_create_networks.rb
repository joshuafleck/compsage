class CreateNetworks < ActiveRecord::Migration
  def self.up
    create_table :networks do |t|
      t.column :title,           :string,  :limit => 128, :null => false
      t.column :description,     :string,  :limit => 512
      t.column :created_at,      :timestamp
      t.column :public,          :boolean
      t.column :organization_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :networks
  end
end
