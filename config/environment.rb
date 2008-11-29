# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = { :session_key => "_myapp_session", :secret => "535b541d23b19ce0e7a1090c403771d6" }
  config.active_record.observers = :invitation_observer
  
  config.action_mailer.default_url_options = {:host => "localhost", :port => 3000}
  config.action_mailer.perform_deliveries = false
  # config.gem 'fiveruns_tuneup', :version => '>=0.8.10'
  config.gem 'rubyist-aasm', :version => '>=2.0.1', :lib => 'aasm', :source => 'http://gems.github.com'
  config.gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'
  config.gem 'beanstalk-client', :version => '>=1.0.2'
  config.gem 'will_paginate', :version => '>=2.2.2'
  config.gem 'activemerchant', :version => '>=1.4.0', :lib => 'active_merchant'  
  config.load_paths += ["app/workers", "app/builders"]
  
  ExceptionNotifier.exception_recipients = %w(eazydp@gmail.com brian.terlson@gmail.com flec0025@umn.edu)
  #uncomment if you want to receive exception emails
  #local_addresses.clear
end
