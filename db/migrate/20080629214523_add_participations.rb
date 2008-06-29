class AddParticipations < ActiveRecord::Migration
  def self.up
    remove_column :invitations, 'accepted'
    remove_column :responses, 'responder_type'
    remove_column :responses, 'responder_id'
    add_column :responses, 'participation_id', :integer, :null => false
    
    create_table :participations do |t|
      t.references :participant, :polymorphic => true
      t.references :survey
      
      t.timestamps
    end
    
  end

  def self.down
    add_column :invitations, 'accepted', :boolean, :default => false, :null => false
    add_column :responses, 'responder_type', :string, :limit => 30
    add_column :responses, 'responder_id', :integer
    # remove_column :responses, 'participation_id'
    
    drop_table :participations
  end
end
