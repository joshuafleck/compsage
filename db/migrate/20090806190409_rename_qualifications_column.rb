class RenameQualificationsColumn < ActiveRecord::Migration
  def self.up
    rename_column :responses, :qualifications, :comments
  end

  def self.down
  end
end
