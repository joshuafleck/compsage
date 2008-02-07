class CreateSurveys < ActiveRecord::Migration
  def self.up
    create_table :surveys do |t|
      t.column  :sponsor,   :integer
      t.column  :title,             :string,    :limit => 128,  :null => false
      t.column  :description,       :text  
      t.column  :start_date,        :timestamp
      t.column  :end_date,          :timestamp
    end
  end

  def self.down
    drop_table :surveys
  end
end
