class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.column :parent_id,   :integer
      t.column :title,       :string,  :limit => 128
      t.column :body,        :text
      t.column :created_at,  :datetime, :null => false
      t.column :sender_id,   :integer,  :null => false
      t.column :receiver_id, :integer,  :null => false
      t.column :read,        :boolean      
    end
    
    add_index :messages, :sender_id, :name => "index_messages_on_sender_id"
    add_index :messages, :receiver_id, :name => "index_messages_on_receiver_id"
  end

  def self.down
    drop_table :messages
  end
end
