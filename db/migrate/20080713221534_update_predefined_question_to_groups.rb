class UpdatePredefinedQuestionToGroups < ActiveRecord::Migration
  def self.up
    add_column :predefined_questions, "title", :string
    add_column :predefined_questions, "question_hash", :text
    
    remove_column :predefined_questions, "text"
    remove_column :predefined_questions, "question_type"
    remove_column :predefined_questions, "question_parameters"
    remove_column :predefined_questions, "html_parameters"
    remove_column :predefined_questions, "options"
  end

  def self.down
    remove_column :predefined_questions, "title"
    remove_column :predefined_questions, "question_hash"
    
    add_column :predefined_questions, 'text', :string, :limit => 1000
    add_column :predefined_questions, 'question_type', :string, :limit => 30
    add_column :predefined_questions, 'html_parameters', :string, :limit => 512
    add_column :predefined_questions, 'question_parameters', :string, :limit => 512
    add_column :predefined_questions, 'options', :text
  end
end
