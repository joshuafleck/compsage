RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = { :session_key => "_compsage_session", :secret => "535b541d23b19ce0e7a1090c403771d6" }
  config.active_record.observers = :discussion_observer
  config.action_controller.use_accept_header = false

  config.gem 'state_machine', :version => '0.7.6'
  config.gem 'beanstalk-client', :version => '1.0.2'
  config.gem 'will_paginate', :version => '2.2.2'
  config.gem 'activemerchant', :version => '1.4.2', :lib => 'active_merchant'  
  config.gem 'prawn', :version => '0.5.1'
  config.gem 'freelancing-god-thinking-sphinx',
              :lib => 'thinking_sphinx',
              :source => 'http://gems.github.com',
              :version => '1.2.8'

  config.gem 'validatable', :version => '1.6.7'
  config.gem 'mbleigh-subdomain-fu', :version => '0.5.3', :lib => 'subdomain-fu'
  config.gem "ambethia-recaptcha", :lib => "recaptcha/rails", :source => "http://gems.github.com", :version => '0.2.2'
  config.gem 'fastercsv', :version => '1.5.0'
  config.gem 'paperclip', :version => '2.3.1.1'
  config.gem 'JasonKing-inline_attachment', :version => '0.4.4', :lib => 'inline_attachment'

  config.load_paths += [RAILS_ROOT + "/app/workers", RAILS_ROOT + "/app/builders"]
end
