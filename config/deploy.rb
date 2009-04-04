set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

### Application Settings
set :application, "compsage"
set :deploy_to, "/var/www/compsage"

### SSH Settings ###
set :user, "deploy"
set :use_sudo, false

### Repository Setup ###
set :scm, :git
set :repository,  "deploy@dev.huminsight.com:/home/git/shawarma"
set :branch, "master"
set :deploy_via, :remote_cache

### Custom Tasks ###
namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
       
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  desc "Copy database.yml file to the project directory"
  task :copy_database_yml, :roles => :app do
    run "cp -pf #{shared_path}/config-files/database.yml #{current_path}/config"
  end
   
  desc "Load predefined questions"
  task :load_pdq, :roles => :app do
    run "cd #{current_path}; rake spec:db:fixtures:load FIXTURES=predefined_questions RAILS_ENV=#{rails_env}"
  end 
  
  desc "Link the logos directory"
  task :link_logos, :role => :app do
    run "ln -s #{shared_path}/logos/ #{current_path}/public/logos; ln -s #{shared_path}/attachment_fu/ #{current_path}/tmp/attachment_fu"
  end
 
  desc "Link thinking_sphinx data directory"
  task :link_ts, :roles => :app do
    run "ln -s #{shared_path}/sphinx #{current_path}/db/sphinx"
  end  


end

after 'deploy', 'deploy:link_logos', 'deploy:link_ts', 'deploy:copy_database_yml', 'deploy:migrations', 'deploy:load_pdq'
