class AddPredefinedQuestionIdToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, "predefined_question_id", :integer
  end

  def self.down
    remove_column :questions, "predefined_question_id"
  end
end
