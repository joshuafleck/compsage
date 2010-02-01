class AddSizeToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :size, :integer
  end

  def self.down
    remove_column :organization, :size
  end
end
