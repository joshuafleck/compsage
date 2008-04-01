class CreatePendingAccounts < ActiveRecord::Migration
  def self.up
    create_table :pending_accounts do |t|
      t.column :name,        :string,   :null => false, :limit =>100
      t.column :email,       :string,   :null => false, :limit =>100
      t.column :contact_first_name,     :string,   :null => false, :limit =>100
      t.column :contact_last_name,      :string,   :null => false, :limit =>100
      t.column :phone,       :string,   :null => false,            :limit =>10
      t.column :phone_extension,        :string,   :limit =>4
      t.column :created_at,  :datetime, :null => false
      t.column :key,         :string,   :limit => 40
    end
    
    add_index :pending_accounts, :key
    
  end

  def self.down
    drop_table :pending_accounts
  end
end
