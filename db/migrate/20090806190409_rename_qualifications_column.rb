class RenameQualificationsColumn < ActiveRecord::Migration
  def self.up
    rename_column :responses, :qualifications, :comments
  end

  def self.down
    rename_column :responses, :comments, :qualifications
  end
end
