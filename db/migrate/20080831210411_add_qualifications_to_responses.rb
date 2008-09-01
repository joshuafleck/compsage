class AddQualificationsToResponses < ActiveRecord::Migration
  def self.up
    add_column :responses, 'qualifications', :string, :limit => 100
  end

  def self.down
    remove_column :responses, 'qualifications'
  end
end
