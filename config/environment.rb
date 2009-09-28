# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = { :session_key => "_compsage_session", :secret => "535b541d23b19ce0e7a1090c403771d6" }
  config.active_record.observers = :discussion_observer,:organization_observer
  config.action_controller.use_accept_header = false

  config.gem 'state_machine', :version => '0.7.6'
  config.gem 'beanstalk-client', :version => '1.0.2'
  config.gem 'will_paginate', :version => '2.2.2'
  config.gem 'activemerchant', :version => '1.4.2', :lib => 'active_merchant'  
  config.gem 'prawn', :version => '0.5.1'
  config.gem 'freelancing-god-thinking-sphinx', :lib => 'thinking_sphinx', :source => 'http://gems.github.com', :version => '1.2.8'
  config.gem 'validatable', :version => '1.6.7'

  config.load_paths += [RAILS_ROOT + "/app/workers", RAILS_ROOT + "/app/builders"]
end

# This will include our custom DateHelper method: 'better_time_ago_in_words' in ActionView so it is accessible to our views and email templates
ActionView::Base.send(:include,BetterDateHelper)

# Fix for relative paths when ActionMailer is looking for view templates. Remove after upgrading
#  to next rails version (> 2.3.2)
# https://rails.lighthouseapp.com/projects/8994/tickets/2263-rails-232-breaks-implicit-multipart-actionmailer-tests
module ActionMailer
  class Base
    def template_path
      File.join(template_root, mailer_name)
    end
  end
end


