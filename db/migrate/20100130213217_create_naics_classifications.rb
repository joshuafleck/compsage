class CreateNaicsClassifications < ActiveRecord::Migration
  
  def self.up
    create_table :naics_classifications, :id => false do |t|
      t.integer :code, :null => false
      t.integer :code_2002
      t.string  :description, :null => false
      t.integer :sic_code
      t.integer :lft
      t.integer :rgt
      t.integer :parent_id
    end

    add_index :naics_classifications, :code, :primary_key => :true
    add_index :naics_classifications, :code_2002
    add_index :naics_classifications, :sic_code

    add_column :organizations, :naics_code, :string, :limit => 6
    remove_column :organizations, :industry

    # Hack to load the classifications. The betternestedset plugin is unavailable from the database migration.
    system("rake naics_classification:load RAILS_ENV=#{Rails.env}")

  end

  def self.down
    drop_table :naics_classifications
    add_column :organizations, 'industry', :string, :limit => 100
    remove_column :organizations, :naics_code
  end
end
