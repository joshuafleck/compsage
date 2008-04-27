class PolymorphicSupport < ActiveRecord::Migration
  def self.up
    add_column :responses, 'responder_type', :string, :limit => 30
    add_column :responses, 'responder_id', :integer
    add_index :responses, ['question_id', 'responder_id']
    
    remove_column :responses, 'organization_id'
    remove_column :responses, 'external_survey_invitation_id'
    remove_index :responses, 'question_id_and_organization_id'
    
    add_column :discussions, 'responder_type', :string, :limit => 30
    add_column :discussions, 'responder_id', :integer
    add_index :discussions, ['responder_id']
    
    remove_column :discussions, 'organization_id'
    remove_column :discussions, 'external_survey_invitation_id'
  end

  def self.down
    remove_column :responses, 'responder_type'
    remove_column :responses, 'responder_id'
    add_column :responses, :external_survey_invitation_id, :integer
    add_column :responses, :organization_id, :integer
    add_index :responses, ['question_id', 'organization_id']
    remove_index :responses, 'question_id_and_responder_id'
    
    remove_column :discussions, 'responder_type'
    remove_column :discussions, 'responder_id'
    add_column :discussions, :external_survey_invitation_id, :integer
    add_column :discussions, :organization_id, :integer
  end
end
