class AddStateToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, 'aasm_state', :string, :limit => 30
    add_index :surveys, 'aasm_state'
  end
  
  def self.down
    remove_column :surveys, 'state'
  end
end
