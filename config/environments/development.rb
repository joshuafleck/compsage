# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Testing actionmailer using mailtrap. Find install and config info here:
#http://matt.blogs.it/entries/00002655.html
  config.action_mailer.default_url_options = {:host => "localhost", :port => 3000}
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.raise_delivery_errors = false
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :domain => "mydomain.net",
  :address => "localhost",
  :port => 2525,
}

#Added factory girl gem for running data builder task
config.gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'

#Each environment has its own keys for interfacing with reCAPTCHA
ENV['RECAPTCHA_PUBLIC_KEY'] = '6LduOQoAAAAAAA_vla7Kqy-BDQEjOwoFJywSRjt0'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LduOQoAAAAAANarTBR5sj66o5baD78l3DIv1Uzi'
