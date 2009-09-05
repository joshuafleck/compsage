# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
  
# Comment out the next line if you're not using RSpec's matchers (should / should_not) in your steps.
require 'cucumber/rails/rspec'

require 'webrat'
require 'factory_girl'

Webrat.configure do |config|
  config.mode = :rails
end

# This will clear the test database between scenario runs.
# We cannot use cucumber transactional fixtures with watir, 
#  as the mongrel instance needs to be able to see the database objects we have created.
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation, {:except => %w[predefined_questions]} # Don't truncate the PDQ table after tests

# Setup for watir browser testing
# Creates a test instance of mongrel on port 3001
require 'firewatir'
port = 3001
base_url = "http://localhost:#{port}"
START_MONGREL="ruby script/server -p #{port} -e #{ENV["RAILS_ENV"]} -d"
system 'rm log/test.log' # Remove any logs from the previous test run
system START_MONGREL
sleep(5) # Give Mongrel some time to start. Since we are running as a daemon, the process returns before the server can rev up.
browser = FireWatir::Firefox.new

# Loads the predefined questions
require 'rake'
Rake.application.add_import(RAILS_ROOT + "/Rakefile")
Rake.application.load_imports
ENV["FIXTURES"] = "predefined_questions"
Rake::Task["spec:db:fixtures:load"].invoke

# Setup thinking sphinx
Rake::Task["ts:config"].invoke
Rake::Task["ts:index"].invoke
Rake::Task["ts:start"].invoke

# This block is run before every feature test
Before do
  DatabaseCleaner.start # Tells the db cleaner you are starting a transaction
  Rake::Task["ts:index"].invoke # Re-indexes sphinx
  @testing_javascript = false # This flag tells our cucumber steps how to test (webrat or watir)
  @browser = browser # This is the browser to be used in watir tests
  @base_url = base_url # This is the base URL for watir tests
  @current_organization = Factory.create(:organization) # We need an organization for most steps, have one ready
  @current_survey_invitation = Factory.create(:sent_external_survey_invitation) # We need an external invitation for many steps, have one ready
end

# This block is run after every feature test
After do
  DatabaseCleaner.clean # Clears the test database
end

# This will close the browser and kill the mongrel instance when testing is complete
at_exit do
  Rake::Task["ts:stop"].invoke # Stops the searchd daemon
  browser.close # Closes the watir browser
  system "kill `ps aux | grep -e '#{START_MONGREL}' | grep -v grep | awk '{ print $2 }'`" # Kills the mongrel instance
end

