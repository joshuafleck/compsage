class CreateNetworks < ActiveRecord::Migration
  def self.up
    create_table :networks do |t|
      t.column :title,           :string,  :limit => 128, :null => false
      t.column :description,     :string,  :limit => 512
      t.column :created_at,      :timestamp, :null => false
      t.column :public,          :boolean
      t.column :owner_id, :integer, :null => true
    end
  end

  def self.down
    drop_table :networks
  end
end
