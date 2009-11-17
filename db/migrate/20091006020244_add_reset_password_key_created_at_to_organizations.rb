class AddResetPasswordKeyCreatedAtToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, 'reset_password_key_created_at', :datetime
  end

  def self.down
    remove_column :organizations, 'reset_password_key_created_at'
  end
end
