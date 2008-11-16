class AddResetPasswordKeyToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, 'reset_password_key', :string, :limit => 40
    add_column :organizations, 'reset_password_key_expires_at', :datetime
  end

  def self.down
    remove_column :organizations, 'reset_password_key'
    remove_column :organizations, 'reset_password_key_expires_at'
  end
end
