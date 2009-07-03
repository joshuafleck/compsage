class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.references :survey, :null => false
      t.string :organization_name, :contact_name, :address_line_1, :city, :state, :null => false, :limit => 100
      t.string :address_line_2, :limit => 100
      t.string :zip_code, :limit => 5, :null => false
      t.string :phone, :limit => 10, :null => false
      t.string :phone_extension, :limit => 6
      t.integer :amount, :null => false
      t.datetime :invoiced_at
      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
