ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
require 'cucumber/rails/rspec'
require 'webrat'
require 'factory_girl'
require 'rake'
require 'database_cleaner'
require 'firewatir'

require 'features/steps/text_box_extension.rb'
require 'features/helpers/organization_helper'
require 'features/helpers/wait_helper'
require 'features/helpers/dom_interface_helper'

Webrat.configure do |config|
  config.mode = :rails
end

# MONKEY PATCH ALERT!
# Prawnto currently checks whether the request is SSL by attempting to downcase the env var SERVER_PROTOCOL. Webrat
# does not set this. Prawnto should instead as if the request is SSL via standard means (env.request.ssl?), but it
# doesn't. So, since all of our requests will not be over SSL, let us simply make SSL request return false, thus
# avoiding the whole issue.
module Prawnto
  module TemplateHandler
    class CompileSupport
      def ssl_request?
        false
      end
    end
  end
end

# Load the predefined questions
Rake.application.add_import(RAILS_ROOT + "/Rakefile")
Rake.application.load_imports
ENV["FIXTURES"] = "predefined_questions"
Rake::Task["spec:db:fixtures:load"].invoke

# Setup thinking sphinx
ThinkingSphinx.deltas_enabled = true
ThinkingSphinx.updates_enabled = true
ThinkingSphinx.suppress_delta_output = true
ts = ThinkingSphinx::Configuration.instance
ts.controller.start
ts.controller.index

# This will clear the test database between scenario runs.
# We cannot use cucumber transactional fixtures with watir, 
#  as the mongrel instance needs to be able to see the database objects we have created.
DatabaseCleaner.strategy = :truncation, {:except => %w[predefined_questions]} # Don't truncate the PDQ table after tests

## Setup for watir browser testing

# If running headless, set this environment variable. This will start a virtual framebuffer and run FF with the vfb display.
run_headless = ENV["RUN_HEADLESS"]
if run_headless then
  system 'Xvfb :99 -ac&'
  sleep(2) # Give Xvfb some time to start
  system 'DISPLAY=:99 firefox -jssh&' # FireWatir runs in an existing FF session, if we have one open one ahead of time.
end

# Creates a test instance of mongrel on port 3001
FireWatir::TextField.send(:include, TextBoxExtension)
port = 3001
base_url = "http://localhost:#{port}"
START_MONGREL = "ruby script/server -p #{port} -e #{ENV["RAILS_ENV"]} -d"
KILL_MONGREL_COMMAND = "kill `ps aux | grep -e '#{START_MONGREL}' | grep -v grep | awk '{ print $2 }'`"
system 'rm log/test.log' # Remove any logs from the previous test run
system START_MONGREL
sleep(5) # Give Mongrel some time to start. Since we are running as a daemon, the process returns before the server can rev up.

begin
  browser = FireWatir::Firefox.new
rescue Watir::Exception::UnableToStartJSShException
  system KILL_MONGREL_COMMAND
  raise Watir::Exception::UnableToStartJSShException
end

# Add some helpers to our world object.
World(OrganizationHelper)
World(WaitHelper)
World(DomInterfaceHelper)

# This block is run before every feature test
Before do
  DatabaseCleaner.start # Tells the db cleaner you are starting a transaction
  ts.controller.index # Index thinking sphinx.
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
  ts.controller.stop
  browser.close # Closes the watir browser
  system KILL_MONGREL_COMMAND
  if run_headless then
    # call to browser.close, above, kills FF
    system "kill `ps aux | grep -e 'Xvfb :99' | grep -v grep | awk '{ print $2 }'`"
  end
end

