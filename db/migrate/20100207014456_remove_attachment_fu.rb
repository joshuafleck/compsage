class RemoveAttachmentFu < ActiveRecord::Migration
  def self.up
    drop_table :logos
  end

  def self.down
    create_table "logos", :force => true do |t|
      t.column :organization_id, :integer, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :parent_id,  :integer
      t.column :content_type, :string, :null => false
      t.column :filename, :string, :null => false
      t.column :thumbnail, :string
      t.column :size, :integer, :null => false
      t.column :width, :integer
      t.column :height, :integer
    end
  end
end
