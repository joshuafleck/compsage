class RemoveOrganizationColumnsAndPendingAccounts < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :association_member_initialization_key
    remove_column :organizations, :association_member_initialization_key_created_at
    drop_table :pending_accounts
  end

  def self.down
    add_column :organizations, 'association_member_initialization_key', :string, :limit => 40
    add_column :organizations, 'association_member_initialization_key_created_at', :datetime
    create_table :pending_accounts do |t|
      t.column :organization_name,      :string,   :null => false, :limit =>100
      t.column :email,                  :string,   :null => false, :limit =>100
      t.column :contact_first_name,     :string,   :null => false, :limit =>100
      t.column :contact_last_name,      :string,   :null => false, :limit =>100
      t.column :phone,                  :string,   :null => false,            :limit =>10
      t.column :phone_extension,        :string,   :limit =>6
      t.column :created_at,             :datetime, :null => false
      t.column :key,                    :string,   :limit => 40
      t.column :accepted,               :boolean,  :default => false, :null => false
    end
    
    add_index :pending_accounts, :key    
  end
end


