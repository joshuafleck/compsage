class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.column :network_id,  :integer, :null => true
      t.column :survey_id,   :integer, :null => true
      t.column :invitee_id,  :integer
      t.column :inviter_id,  :integer
      t.column :created_at,  :datetime
      t.column :type,        :string
    end
    
    add_index :invitations, [:network_id, :invitee_id], :name => "index_invitations_on_network_id_and_invitee_id"
    add_index :invitations, [:survey_id, :inviter_id], name => "index_invitations_on_network_id_and_inviter_id"
    add_index :invitations, :invitee_id, :name => "index_invitations_on_invitee_id"
    add_index :invitations, :inviter_id, :name => "index_invitations_on_inviter_id"
  end

  def self.down
    drop_table :invitations
  end
end
