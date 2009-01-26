class AddUnitsToResponse < ActiveRecord::Migration
  def self.up
    add_column :responses, 'unit', :string, :limit => 20
  end

  def self.down
    remove_column :responses, 'unit'
  end
end
