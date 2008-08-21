class CreateSurveySubscriptions < ActiveRecord::Migration
  def self.up
    create_table :survey_subscriptions do |t|
      t.references :survey, :organization, :null => false
      t.string :relationship, :limit => 20, :null => false
    end
    
    add_index :survey_subscriptions, ['survey_id', 'organization_id'], :unique => true
    add_index :survey_subscriptions, ['organization_id', 'relationship']
  end

  def self.down
    drop_table :survey_subscriptions
  end
end
