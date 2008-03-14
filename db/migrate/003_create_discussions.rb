class CreateDiscussions < ActiveRecord::Migration
  def self.up
    create_table :discussions do |t|
      t.column :parent_id,       :integer
      t.column :lft,             :integer,  :null => false
      t.column :rgt,             :integer,  :null => false
      t.column :survey_id,       :integer,  :null => false
      t.column :organization_id, :integer,  :null => false
      t.column :created_at,      :datetime, :null => false
      t.column :title,           :string,  :limit => 128
      t.column :body,            :text, :limit => 1024
      t.column :times_reported   :int,  :default => 0
    end
    
    add_index :discussions, [:survey_id,:parent_id], :name => "index_discussions_on_survey_id_parent_id"
  end

  def self.down
    drop_table :discussions
  end
end
