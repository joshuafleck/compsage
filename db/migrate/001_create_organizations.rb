class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table "organizations", :force => true do |t|
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :last_login_at,             :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :public,                    :boolean
      t.column :location,                  :string,  :limit => 64
      t.column :contact_name,              :string,  :limit => 128
      t.column :city,                      :string,  :limit => 50
      t.column :state,                     :string,  :limit => 30
    end
    
    add_index :organizations, :email, :name => "index_organizations_on_email"
  end

  def self.down
    drop_table "organizations"
  end
end
