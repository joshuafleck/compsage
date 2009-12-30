# Settings specified here will take precedence over those in config/environment.rb

#Required for ruby_inline, to prevent 'Define INLINEDIR or HOME in your environment and try again' error
ENV['INLINEDIR'] = '/home/www'

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = {:host => "dev.huminsight.com", :port => 81}
  
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :domain => "josh-laptop",
  :address => "josh-laptop",
  :port => 25
}

#Each environment has its own keys for interfacing with reCAPTCHA
ENV['RECAPTCHA_PUBLIC_KEY'] = '6LdqOQoAAAAAADLPYsEj5_35MyQpnj3ai2fSDb3R'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LdqOQoAAAAAAPak6jni9RqIgp2qBlZDfRpDDsAT'



