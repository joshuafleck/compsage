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

include WaitHelper
include URLHelper

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
ts.controller.index
ts.controller.start


# This will clear the test database between scenario runs.
# We cannot use cucumber transactional fixtures with watir, 
#  as the mongrel instance needs to be able to see the database objects we have created.
DatabaseCleaner.strategy = :truncation, {:except => %w[predefined_questions]} # Don't truncate the PDQ table after tests

# Starting with Cucumber version 1.3.102, Cucumber breaks not using transactional fixtures. This monkeypatch ensures that
# use_transactional_fixtures is always false. Remove this once cucumber #457 is functioning properly.
class << Cucumber::Rails::World
  def use_transactional_fixtures
    false
  end
  def use_transactional_fixtures=(other)
    # do nothing
  end
end

# another hack regarding errors coming from redirects via subdomain
class Webrat::Session
  alias internal_redirect? redirect?
end


## Setup for watir browser testing

# If running headless, set this environment variable. This will start a virtual framebuffer and run FF with the vfb display.
run_headless = ENV["RUN_HEADLESS"]
XVFB = "Xvfb :99 -ac"
FIREFOX = "firefox -jssh --display=:99.0"
if run_headless then
  system "#{XVFB} &"
  wait_for_process(XVFB) 
  system "DISPLAY=:99 #{FIREFOX} &" # FireWatir runs in an existing FF session, if we have one open ahead of time.
  wait_for_process(FIREFOX) 
end

# Creates a test instance of mongrel on port 3001
FireWatir::TextField.send(:include, TextBoxExtension)
port = 3001
subdomain = "sub"
base_url = "http://#{subdomain}.localhost:#{port}"
KILL_COMMAND = "kill `ps aux | grep -e '<process>' | grep -v grep | awk '{ print $2 }'`"
MONGREL = "ruby script/server -p #{port} -e #{ENV["RAILS_ENV"]} -d"
system 'rm log/test.log' # Remove any logs from the previous test run
system MONGREL
wait_for_process(MONGREL)

begin
  browser = FireWatir::Firefox.new
rescue Watir::Exception::UnableToStartJSShException
  ts.controller.stop
  system KILL_COMMAND.gsub("<process>",MONGREL)
  raise Watir::Exception::UnableToStartJSShException
end

# Add some helpers to our world object.
World(OrganizationHelper)
World(WaitHelper)
World(DomInterfaceHelper)
World(URLHelper)

# This block is run before every feature test
Before do
  DatabaseCleaner.start # Tells the db cleaner you are starting a transaction
  ts.controller.index # Index thinking sphinx.
  @testing_javascript = false # This flag tells our cucumber steps how to test (webrat or watir)
  @browser = browser # This is the browser to be used in watir tests
  @base_url = base_url # This is the base URL for watir tests
  @subdomain = subdomain # This is the subdomain for all webrat tests for AI. Need to set variable in route creation.
  @current_organization = Factory.create(:organization) # We need an organization for most steps, have one ready
  @current_association_by_owner = Factory.create(:association) # association owner for setting steps
  @current_survey_invitation = Factory.create(:sent_external_survey_invitation) # We need an external invitation for many steps, have one ready
  @current_association = Factory.create(:association, :subdomain => @subdomain) # association for association based specs
end

# This block is run after every feature test
After do
  DatabaseCleaner.clean # Clears the test database
  #We need to delete created PDQs, but not all, so it must be done seperately
  @current_association_by_owner.predefined_questions.each do |pdq|
    pdq.delete
  end
end

# This will close the browser and kill the mongrel instance when testing is complete
at_exit do
  ts.controller.stop
  browser.close # Closes the watir browser
  system KILL_COMMAND.gsub("<process>",MONGREL)
  if run_headless then
    system KILL_COMMAND.gsub("<process>",FIREFOX)
    system KILL_COMMAND.gsub("<process>",XVFB)
  end
end

