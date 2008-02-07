class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.column :network_id,  :integer, :null => true
      t.column :survey_id,   :integer, :null => true
      t.column :invitee_id,  :integer, :null => false
      t.column :invitor_id,  :integer, :null => false
      t.column :created_at,  :timestamp, :null => false
      t.column :type,        :string, :null => false
    end
  end

  def self.down
    drop_table :invitations
  end
end
