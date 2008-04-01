class CreateNetworks < ActiveRecord::Migration
  def self.up
    create_table :networks do |t|
      t.column :title,           :string,   :limit => 128,   :null => false
      t.column :description,     :text,     :limit => 1024
      t.column :created_at,      :datetime, :null => false
      t.column :owner_id,        :integer,  :null => false
    end
    
    add_index :networks, :owner_id
  end

  def self.down
    drop_table :networks
  end
end
