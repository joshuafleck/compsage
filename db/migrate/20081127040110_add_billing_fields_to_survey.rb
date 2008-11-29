class AddBillingFieldsToSurvey < ActiveRecord::Migration
  def self.up
    add_column :surveys, 'billing_error_description', :string
    add_column :surveys, 'billing_authorization', :string, :limit => 20
    add_column :surveys, 'capture_transaction_id', :string, :limit => 20
    add_column :surveys, 'authorization_transaction_id', :string, :limit => 20
    add_column :surveys, 'void_transaction_id', :string, :limit => 20
    add_column :surveys, 'capture_authorization_code', :string, :limit => 6
  end

  def self.down
    remove_column :surveys, 'capture_authorization_code'
    remove_column :surveys, 'void_transaction_id'
    remove_column :surveys, 'authorization_transaction_id'
    remove_column :surveys, 'capture_transaction_id'
    remove_column :surveys, 'billing_authorization'
    remove_column :surveys, 'billing_error_description'
  end
end
