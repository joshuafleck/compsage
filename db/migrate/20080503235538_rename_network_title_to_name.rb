class RenameNetworkTitleToName < ActiveRecord::Migration
  def self.up
    rename_column 'networks', 'title', 'name'
  end

  def self.down
    rename_column 'networks', 'name', 'title'
  end
end
