class CreateDiscussions < ActiveRecord::Migration
  def self.up
    create_table :discussions do |t|
      t.column :parent,          :integer, :null => true
      t.column :survey_id,       :integer
      t.column :organization_id, :integer
      t.column :created_at,      :timestamp
      t.column :title,           :string,  :limit => 128
      t.column :body,            :text
    end
  end

  def self.down
    drop_table :discussions
  end
end
