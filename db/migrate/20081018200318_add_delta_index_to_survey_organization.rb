class AddDeltaIndexToSurveyOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, 'delta', :boolean
    add_column :surveys, 'delta', :boolean
  end

  def self.down
    remove_column :organizations, 'delta'
    remove_column :surveys, 'delta'
  end
end
