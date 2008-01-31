class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.column :network_id,  :integer, :null => true
      t.column :survey_id,   :integer, :null => true
      t.column :invitee_id,  :integer
      t.column :inviter_id,  :integer
      t.column :created_at,  :timestamp
      t.column :status,      :string,  :limit => 10, :default => "active"
    end
  end

  def self.down
    drop_table :invitations
  end
end
