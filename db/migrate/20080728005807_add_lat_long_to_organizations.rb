class AddLatLongToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, 'latitude', :float
    add_column :organizations, 'longitude', :float
  end

  def self.down
    remove_column :organizations, 'latitude'
    remove_column :organizations, 'longitude'
  end
end
