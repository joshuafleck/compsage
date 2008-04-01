class CreateSurveys < ActiveRecord::Migration
  def self.up
    create_table :surveys do |t|
      t.column  :sponsor_id,        :integer,   :null => false
      t.column  :title,             :string,    :limit => 128,  :null => false
      t.column  :description,       :text  
      t.column  :created_at,        :datetime
      t.column  :end_date,          :datetime
    end
    
    add_index :surveys, :sponsor_id
  end

  
  def self.down
    drop_table :surveys
  end
end
