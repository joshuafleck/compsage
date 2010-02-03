class CreateNaicsClassifications < ActiveRecord::Migration
  def self.up
    create_table :naics_classifications, :id => false do |t|
      t.integer :code, :null => false
      t.integer :code_2002
      t.string  :description, :null => false

      t.integer :sic_code
    end

    add_index :naics_classifications, :code, :primary_key => :true
    add_index :naics_classifications, :code_2002
    add_index :naics_classifications, :sic_code

    add_column :organizations, :naics_code, :string, :limit => 6
    remove_column :organizations, :industry

    puts "Importing NAICS classifications."

    classification_file = File.expand_path(File.join(RAILS_ROOT, 'utils/classification_data/naics_codes.csv'))

    FasterCSV.foreach(classification_file) do |c|
      nc = NaicsClassification.new(
        :code_2002 => c[1],
        :sic_code => c[2],
        :description => c[3]
      )
      nc.code = c[0]
      nc.save!
    end
  end

  def self.down
    drop_table :naics_classifications
    add_column :organizations, 'industry', :string, :limit => 100
    remove_column :organizations, :naics_code
  end
end
