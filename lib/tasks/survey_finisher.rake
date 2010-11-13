require 'rubygems'

namespace :sf do

  desc "Will locate any running surveys past their end date and finish them"
  task :run, :needs => [:environment] do |task|
  
    lockfile = "survey_finisher.lockfile"
  
    puts "Checking for existing lock file..."
  
    if File.exist? lockfile
      $stderr.puts("Unable to run survey finisher task. Lockfile exists: "+lockfile)
    else
      begin
        FileUtils.touch lockfile
        
        puts "Wrote lock file. Retrieving running surveys..."

        surveys = Survey.with_aasm_state(:running).find(:all, :conditions => ['end_date < ?', Time.now])
    
        surveys.each do |survey|
          puts "Finishing survey:"+survey.id.to_s
          survey.finish! if survey.running? 
        end
        
        puts "Finished "+surveys.size.to_s+" surveys."
      ensure
        FileUtils.rm lockfile
        puts "Removed lock file."
      end
    end
    
    puts "Survey finisher complete."
  end
  
end      
