class CreateExternalInvitations < ActiveRecord::Migration
  def self.up
    create_table :external_invitations do |t|
      t.column :network_id,  :integer
      t.column :survey_id,   :integer
      t.column :inviter_id,  :integer,  :null => false
      t.column :created_at,  :datetime, :null => false
      t.column :type,        :string,   :null => false
      t.column :status,      :boolean,  :null => false, :default => false
      t.column :name,        :string,   :null => false, :limit => 100
      t.column :email,       :string,   :null => false
      t.column :key,         :string,   :null => false, :limit => 40
    end
    
    add_index :external_invitations, [:inviter_id, :type], :name => "index_external_invitations_on_inviter_id_and_type"
    add_index :external_invitations, :network_id, :name => "index_external_invitations_on_network_id"
    add_index :external_invitations, :survey_id, :name => "index_external_invitations_on_survey_id"
    add_index :external_invitations, :key, :name => "index_external_invitations_on_key"
    
  end

  def self.down
    drop_table :external_invitations
  end
end
