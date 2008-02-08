class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.column :network_id,  :integer, :null => true
      t.column :survey_id,   :integer, :null => true
      t.column :invitee_id,  :integer
      t.column :invitor_id,  :integer
      t.column :created_at,  :datetime
      t.column :type,        :string
    end
  end

  def self.down
    drop_table :invitations
  end
end
