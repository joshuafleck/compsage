class AddPoNumberToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, 'purchase_order_number', :string, :limit => 50
  end

  def self.down
    remove_column :invoices, 'purchase_order_number'
  end
end
