class CreateResponses < ActiveRecord::Migration
  def self.up
    create_table :responses do |t|
      t.integer 'question_id', 'organization_id', :null => false
      t.string 'textual_response'
      t.float 'numerical_response'
      t.timestamps
    end
    
    add_index :responses, ['question_id', 'organization_id']
  end

  def self.down
    drop_table :responses
  end
end
