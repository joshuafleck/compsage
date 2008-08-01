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
end