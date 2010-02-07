require 'rubygems'

namespace :naics_classification do

  desc "Will clear and reload the naics classification taxonomy"
  task :load, :needs => [:environment] do |task|
  
    puts "Truncating the naics_classifications table."

    ActiveRecord::Base.connection.execute('TRUNCATE TABLE naics_classifications')
    
    puts "Importing NAICS classifications."

    classification_file = File.expand_path(File.join(RAILS_ROOT, 'utils/classification_data/naics_codes.csv'))

    # We use the stack to track and build the taxonomical relationships, since the CSV file is ordered by code
    naics_stack = []  
    FasterCSV.foreach(classification_file) do |c|
    
      nc = NaicsClassification.new(
        :code_2002 => c[1],
        :sic_code => c[2],
        :description => c[3]
      )
      nc.code = c[0]
      nc.save!
      
      previous_node = nil
      # If we are a root node, the stack will be empty
      if previous_node = naics_stack.last then
      
        # If the current node is deeper than the previous node, make the current node a child of the previous
        if previous_node.code.to_s.length < nc.code.to_s.length then
        
          nc.move_to_child_of previous_node
          
        # If the current node is the same depth as the previous node, 
        #  make the current node a child of the previous node's parent
        elsif previous_node.code.to_s.length == nc.code.to_s.length then
        
          nc.move_to_child_of previous_node.parent
          naics_stack.pop              
          
        # The current node is shallower than the previous node, we need to go back up the tree to find its parent    
        else        
          
          while previous_node && previous_node.code.to_s.length > nc.code.to_s.length do
            previous_node = naics_stack.pop 
          end
          
          # Verify we found an ancestor node, and if so, make the current node its child 
          ancestor_node = nil      
          if (ancestor_node = naics_stack.last) then
            nc.move_to_child_of ancestor_node
          end       
          
        end
      end
      
      naics_stack = naics_stack.push nc
            
    end    
  end
  
end  
