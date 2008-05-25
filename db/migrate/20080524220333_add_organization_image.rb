class AddOrganizationImage < ActiveRecord::Migration
  def self.up
    add_column :organizations, 'image', :string, :limit => 100
  end
  
  def self.down
    remove_column :organizations, 'image'
  end
  
end
