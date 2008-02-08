class CreateDiscussions < ActiveRecord::Migration
  def self.up
    create_table :discussions do |t|
      t.column :parent_id,       :integer
      t.column :lft,             :integer
      t.column :rgt,             :integer
      t.column :survey_id,       :integer,  :null => false
      t.column :organization_id, :integer,  :null => false
      t.column :created_at,      :datetime, :null => false
      t.column :title,           :string,  :limit => 128
      t.column :body,            :text, :limit => 1024
    end
  end

  def self.down
    drop_table :discussions
  end
end
