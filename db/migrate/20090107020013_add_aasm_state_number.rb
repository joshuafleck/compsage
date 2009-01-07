class AddAasmStateNumber < ActiveRecord::Migration
  def self.up
    add_column :surveys, 'aasm_state_number', :integer
  end

  def self.down
    remove_column :surveys, 'aasm_state_number'
  end
end
