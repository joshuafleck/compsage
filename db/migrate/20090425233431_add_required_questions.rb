class AddRequiredQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, 'required', :boolean, :default => 0
  end

  def self.down
    remove_column :questions, 'required'
  end
end
