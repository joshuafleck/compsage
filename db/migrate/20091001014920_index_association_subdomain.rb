class IndexAssociationSubdomain < ActiveRecord::Migration
  def self.up
    add_index :associations, :subdomain, :unique => true
  end

  def self.down
    remove_index :associations, :column => :subdomain
  end
end
