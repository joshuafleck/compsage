class CreateDiscussions < ActiveRecord::Migration
  def self.up
    create_table :discussions do |t|
      t.column :parent_id,       :integer, :null => true
      t.column :survey_id,       :integer, :null => false
      t.column :organization_id, :integer, :null => false
      t.column :created_at,      :timestamp, :null => false
      t.column :title,           :string,  :limit => 128
      t.column :body,            :text, :limit => 1024
    end
  end

  def self.down
    drop_table :discussions
  end
end
