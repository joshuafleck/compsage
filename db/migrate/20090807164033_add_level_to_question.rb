class AddLevelToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, 'level', :integer,  :null => false
  end

  def self.down
    remove_column :questions, 'level'
  end
end
