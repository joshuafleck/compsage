require 'rubygems'

namespace :pdq do

  desc "Will clear and reload the standard predefined questions"
  task :load, :needs => [:environment] do |task|
  
  
    puts "Deleting standard PDQs from the predefined_questions table."

    ActiveRecord::Base.connection.execute('DELETE FROM predefined_questions WHERE association_id IS NULL')
    
    puts "Loading PDQs."

    pdq_file = File.expand_path(File.join(RAILS_ROOT, 'config/pdq.yml'))
    
    # Creates an array of PDQs
    pdqs = YAML.load_file(pdq_file)
    
    pdqs.each do |pdq| 
    
      # PDQs cannot be saved directly, so we copy them to a new object before saving
      pdq_copy = PredefinedQuestion.new(pdq.attributes)
      pdq_copy.id = pdq.id
      pdq_copy.save
    
      puts "Saving pdq: #{pdq.name}"
        
    end
  
  end
  
end
  
