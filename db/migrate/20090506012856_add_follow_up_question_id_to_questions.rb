class AddFollowUpQuestionIdToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, 'follow_up_question_id', :integer
  end

  def self.down
    remove_column :questions, 'follow_up_question_id'
  end
end
