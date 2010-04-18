class AddDefaultToPdq < ActiveRecord::Migration
  def self.up
    add_column :predefined_questions, 'default', :boolean, :default => 0
  end

  def self.down
    remove_column :predefined_questions, 'default'
  end
end
