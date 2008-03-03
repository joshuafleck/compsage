class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.column :network_id,  :integer
      t.column :survey_id,   :integer
      t.column :invitee_id,  :integer,  :null => false
      t.column :inviter_id,  :integer,  :null => false
      t.column :created_at,  :datetime, :null => false
      t.column :type,        :string,   :null => false
      t.column :status,      :boolean,  :null => false, :default => false
    end
    
    add_index :invitations, [:invitee_id, :type], :name => "index_invitations_on_invitee_id_and_type"
    add_index :invitations, [:inviter_id, :type], :name => "index_invitations_on_inviter_id_and_type"
  end

  def self.down
    drop_table :invitations
  end
end
