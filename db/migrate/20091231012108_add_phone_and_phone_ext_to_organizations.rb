class AddPhoneAndPhoneExtToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :phone, :string, :limit =>10
    add_column :organizations, :phone_extension, :string, :limit =>10
  end

  def self.down
    remove_column :organizations, :phone
    remove_column :organizations, :phone_extension
  end
end
