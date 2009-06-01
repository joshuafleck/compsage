class SurveyJobTitleNullable < ActiveRecord::Migration
  def self.up
    change_column :surveys, :job_title, :string, :limit => 128,  :null => true
  end

  def self.down
    change_column :surveys, :job_title, :string, :limit => 128,  :null => false
  end
end
