class RenameCustomQuestionTypeToQuestionType < ActiveRecord::Migration
  def self.up
    rename_column :questions, :custom_question_type, :question_type
  end

  def self.down
    rename_column :questions, :question_type, :custom_question_type
  end
end
