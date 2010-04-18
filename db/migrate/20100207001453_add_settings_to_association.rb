class AddSettingsToAssociation < ActiveRecord::Migration
  def self.up
    add_column :associations, :member_greeting, :text
    add_column :associations, :contact_name, :string
    rename_column :associations, :owner_email, :contact_email
    add_column :associations, :contact_phone, :string, :limit => 10
    add_column :associations, :contact_phone_extension, :string, :limit => 10
  end

  def self.down
    remove_column :associations, :contact_phone_extension
    remove_column :associations, :contact_phone
    rename_column :associations, :contact_email, :owner_email
    remove_column :associations, :contact_name
    remove_column :associations, :member_greeting
  end
end
