class AddCustomQuestionTypeToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, 'custom_question_type', :string
  end

  def self.down
    remove_column :questions, 'custom_question_type'
  end
end
