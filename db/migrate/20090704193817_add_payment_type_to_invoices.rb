class AddPaymentTypeToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, 'payment_type', :string, :limit => 50, :null => false
  end

  def self.down
    remove_column :invoices, 'payment_type'
  end
end
