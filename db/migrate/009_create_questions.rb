class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.integer 'survey_id', 'position', :null => false
      t.string 'text', :limit => 1000
      t.string 'question_type', :limit => 30
      t.string 'question_parameters', 'html_parameters', :limit => 512
      t.text 'options'
    end
    
    add_index :questions, 'survey_id'
  end

  def self.down
    drop_table :questions
  end
end
