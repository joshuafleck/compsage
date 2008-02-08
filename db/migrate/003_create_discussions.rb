class CreateDiscussions < ActiveRecord::Migration
  def self.up
    create_table :discussions do |t|
      t.column :parent_id,       :integer, :null => true
      t.column :lft,             :integer, :null => true
      t.column :rgt,             :integer, :null => true
      t.column :survey_id,       :integer
      t.column :organization_id, :integer
      t.column :created_at,      :datetime
      t.column :title,           :string,  :limit => 128
      t.column :body,            :text, :limit => 1024
    end
  end

  def self.down
    drop_table :discussions
  end
end
