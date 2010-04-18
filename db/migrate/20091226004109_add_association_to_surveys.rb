class AddAssociationToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :association_id, :integer
    add_index  :surveys, :association_id
  end

  def self.down
    remove_column :surveys, :association_id
  end
end
