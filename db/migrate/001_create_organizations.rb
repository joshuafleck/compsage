class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table "organizations", :force => true do |t|
      t.column :email,                     :string, :null => :false
      t.column :crypted_password,          :string, :limit => 40, :null => :false
      t.column :salt,                      :string, :limit => 40, :null => :false
      t.column :created_at,                :datetime, :null => :false
      t.column :updated_at,                :datetime
      t.column :last_login_at,             :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :name,                      :string, :limit => 100, :null => :false
      t.column :location,                  :string, :limit => 60
      t.column :contact_name,              :string, :limit => 100
      t.column :city,                      :string, :limit => 50
      t.column :state,                     :string, :limit => 30
      t.column :zip_code,                  :string, :limit => 5, :null => :false
    end
    
    add_index :organizations, :email
  end

  def self.down
    drop_table "organizations"
  end
end
