class AddAssociationAttributes < ActiveRecord::Migration
  def self.up
    add_column :associations, :owner_email, :string, :null => :false
    add_column :associations, :crypted_password, :string, :limit => 40, :null => :false
    add_column :associations, :salt,  :string, :limit => 40, :null => :false
    
    add_column :predefined_questions, :association_id, :integer, 
                                     :null => :true
                                     
    add_column :logos, :association_id, :integer, :null => :true
    change_column :logos, :organization_id, :integer, :null => :true
  end

  def self.down
    remove_column :associations, :owner_email
    remove_column :associations, :crypted_password
    remove_column :associations, :salt
    remove_column :predefined_questions, :association_id                
    remove_column :logos, :association_id
    change_column :logos, :organization_id, :integer, :null => :false
  end
end
