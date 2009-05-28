class ChangeFollowUpQuestionFields < ActiveRecord::Migration
  def self.up
    rename_column :questions, 'follow_up_question_id', 'parent_question_id'
  end

  def self.down
    rename_column :questions, 'parent_question_id', 'follow_up_question_id'
  end
end
