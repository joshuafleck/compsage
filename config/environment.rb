# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = { :session_key => "_compsage_session", :secret => "535b541d23b19ce0e7a1090c403771d6" }
  config.active_record.observers = :discussion_observer,:organization_observer
  config.action_controller.use_accept_header = false

  #config.gem 'fiveruns_tuneup', :version => '>=0.8.10'
  #config.gem 'rubyist-aasm', :version => '>=2.0.1', :lib => 'aasm', :source => 'http://gems.github.com'
  config.gem 'state_machine', :version => '>=0.7.6'
  config.gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'
  config.gem 'firewatir', :version => '>=1.6.2'
  config.gem 'bmabey-database_cleaner', :lib => 'database_cleaner', :version => '>=0.2.3'
  config.gem 'cucumber', :version => '>=0.3.99'
  config.gem 'beanstalk-client', :version => '>=1.0.2'
  config.gem 'will_paginate', :version => '>=2.2.2'
  config.gem 'webrat', :version => '>=0.4.4'
  config.gem 'activemerchant', :version => '>=1.4.0', :lib => 'active_merchant'  
  config.gem 'prawn', :version => '>=0.4.1'
  config.gem 'freelancing-god-thinking-sphinx', :lib => 'thinking_sphinx', :source => 'http://gems.github.com'

  config.load_paths += [RAILS_ROOT + "/app/workers", RAILS_ROOT + "/app/builders"]
end

# This will include our custom DateHelper method: 'better_time_ago_in_words' in ActionView so it is accessible to our views and email templates
ActionView::Base.send(:include,BetterDateHelper)

