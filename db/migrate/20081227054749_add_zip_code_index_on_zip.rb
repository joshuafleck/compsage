class AddZipCodeIndexOnZip < ActiveRecord::Migration
  def self.up
    add_index :zip_codes, 'zip'
  end

  def self.down
    remove_index :zip_codes, 'zip'
  end
end
