class CreatePredefinedQuestions < ActiveRecord::Migration
  def self.up
    create_table :predefined_questions do |t|
      t.integer 'position'
      t.string 'description'
      t.string 'text', :limit => 1000
      t.string 'question_type', :limit => 30
      t.string 'question_parameters', 'html_parameters', :limit => 512
      t.text 'options'
    end
  end

  def self.down
    drop_table :predefined_questions
  end
end
