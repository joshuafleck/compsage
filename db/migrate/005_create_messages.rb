class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.column :parent,      :integer, :null => true
      t.column :title,       :string,  :limit => 128
      t.column :body,        :text
      t.column :created_at,  :timestamp
      t.column :sender_id,   :integer
      t.column :receiver_id, :integer
    end
  end

  def self.down
    drop_table :messages
  end
end
