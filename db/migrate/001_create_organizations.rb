class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.column :title,          :string,  :limit => 64,   :null => false
      t.column :location,       :string,  :limit => 64
      t.column :public,         :boolean
      t.column :contact_name,   :string,  :limit => 128,  :null => false
      t.column :contact_email,  :string,  :limit => 128,  :null => false 
      t.column :password_salt,  :string,  :limit => 8,    :null => false
      t.column :password_hash,  :string,  :limit => 128,  :null => false
      t.column :city,           :string,  :limit => 50
      t.column :state,          :string,  :limit => 30
    end
  end

  def self.down
    drop_table :organizations
  end
end
