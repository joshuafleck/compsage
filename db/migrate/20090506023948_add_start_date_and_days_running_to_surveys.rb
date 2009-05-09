class AddStartDateAndDaysRunningToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, 'start_date', :datetime
    add_column :surveys, 'days_running', :integer    
  end

  def self.down
    remove_column :surveys, 'start_date'
    remove_column :surveys, 'days_running'
  end
end
