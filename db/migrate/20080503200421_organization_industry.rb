class OrganizationIndustry < ActiveRecord::Migration
  def self.up
    add_column :organizations, 'industry', :string, :limit => 100
  end
  
  def self.down
    remove_column :organizations, 'industry'
  end
  
end
