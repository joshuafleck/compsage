namespace :beanstalk_dispatcher do
  task :start do
    ARGV = ["start"]
    load("lib/beanstalk_controller.rb")
  end
  
  task :stop do
    ARGV = ["stop"]
    load("lib/beanstalk_controller.rb")
  end
  
  task :restart do
    ARGV = ["restart"]
    load("lib/beanstalk_controller.rb")
  end
  
  task :insert_checker_job => :environment do
    Beanstalker.run(:checker, :check_for_closed_surveys, {})
  end
    
  task :insert_rebuilder_job => :environment do
    Beanstalker.run(:rebuilder, :rebuild_sphinx_indexes, {})
  end
end

namespace :bd do
  task :start => "beanstalk_dispatcher:start"
  task :stop => "beanstalk_dispatcher:stop"
  task :restart => "beanstalk_dispatcher:restart"
  task :insert_checker_job => "beanstalk_dispatcher:insert_checker_job"
  task :icj => "beanstalk_dispatcher:insert_checker_job"
  task :insert_rebuilder_job => "beanstalk_dispatcher:insert_rebuilder_job"
  task :irj => "beanstalk_dispatcher:insert_rebuilder_job"
end
