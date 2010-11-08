class CreateOptOuts < ActiveRecord::Migration
  def self.up
    create_table :opt_outs do |t|
      t.string :email
      t.timestamps
    end

    add_index :opt_outs, :email, :unique => true
  end

  def self.down
    drop_table :opt_outs
  end
end
