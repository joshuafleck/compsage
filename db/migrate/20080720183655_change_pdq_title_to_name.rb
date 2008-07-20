class ChangePdqTitleToName < ActiveRecord::Migration
  def self.up
    rename_column :predefined_questions, 'title', 'name'
  end

  def self.down
    rename_column :predefined_questions, 'name', 'title'
  end
end
