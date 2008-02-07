class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.column :parent_id,   :integer, :null => true
      t.column :title,       :string,  :limit => 128
      t.column :body,        :text, :limit => 1024
      t.column :created_at,  :timestamp, :null => false
      t.column :sender_id,   :integer, :null => false
      t.column :receiver_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :messages
  end
end
