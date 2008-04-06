class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.column :network_id,  :integer
      t.column :survey_id,   :integer
      t.column :invitee_id,  :integer
      t.column :inviter_id,  :integer,  :null => false
      t.column :created_at,  :datetime, :null => false
      t.column :type,        :string,   :null => false
      t.column :accepted,    :boolean,  :null => false, :default => false
      t.column :name,        :string,   :limit => 100
      t.column :email,       :string,   :limit => 100
      t.column :key,         :string,   :limit => 40
    end
    
    add_index :invitations, [:invitee_id, :type]
    add_index :invitations, [:inviter_id, :type]
    add_index :invitations, :survey_id
    add_index :invitations, :network_id
    add_index :invitations, :key
  end

  def self.down
    drop_table :invitations
  end
end
