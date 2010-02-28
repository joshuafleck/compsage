# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'
require 'factory_girl'
require File.dirname(__FILE__) + '/factories'

include AuthenticatedTestHelper

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end


##
# rSpec Hash additions.
#
# From 
#   * http://wincent.com/knowledge-base/Fixtures_considered_harmful%3F
#   * Neil Rahilly

class Hash

  ##
  # Filter keys out of a Hash.
  #
  #   { :a => 1, :b => 2, :c => 3 }.except(:a)
  #   => { :b => 2, :c => 3 }

  def except(*keys)
    self.reject { |k,v| keys.include?(k || k.to_sym) }
  end

  ##
  # Override some keys.
  #
  #   { :a => 1, :b => 2, :c => 3 }.with(:a => 4)
  #   => { :a => 4, :b => 2, :c => 3 }
  
  def with(overrides = {})
    self.merge overrides
  end

  ##
  # Returns a Hash with only the pairs identified by +keys+.
  #
  #   { :a => 1, :b => 2, :c => 3 }.only(:a)
  #   => { :a => 1 }
  
  def only(*keys)
    self.reject { |k,v| !keys.include?(k || k.to_sym) }
  end

end


  ##
  # Section for our custom helpers
  #
  #
  #
  
def valid_organization_attributes
  {
    :email => 'brian.terlson@gmail.com',
    :zip_code => '55044',
    :password => 'test12',
    :password_confirmation => 'test12',
    :name => 'Denarius',
    :contact_name => 'Andersen Cooper',
    :city => 'New York',
    :location => 'Eastern Division',
    :state => 'New York',
    :industry => 'Software', 
    :quoted_id => "1",
    :phone => "1234567890"
  }
end

def organization_mock 
  mock_model(
      Organization, 
      valid_organization_attributes)

end

# Will place the organization in the disabled state
def disable_organization(organization)
  organization.is_pending = true
  organization.increment(:times_reported)
  organization.save!
end
  
def valid_survey_attributes
  {
    :end_date => Time.now + 1.day,
    :days_running => 7,
    :start_date => Time.now - 7.days,
    :job_title => 'TEST',
    :sponsor => organization_mock,
    :id => '1',
    :description => 'Descr'
  }
end

def valid_question_attributes
  {
    :position => 1,
    :text => "question 1",
    :response_type => "NumericalResponse"
  }
end

def valid_importer_params
  {'update' => true,
   'create' => true,
   'destroy' => false,
   'headers' => false,
   'classification' => 'naics2007'
   }  
end

def survey_mock 
  mock_model(
      Survey, 
      valid_survey_attributes)
end

def valid_survey(attributes = valid_survey_attributes)
    survey = Survey.new(attributes)
    survey.questions.build(valid_question_attributes)
    survey
end

def valid_csv_file
"Imported Firm, Joe Wilson, joe.wilson@importedfirm.com, 55407, 20, 30
Durgan-Kunze, Mrs. Christy Bogisich, laurence@brekkewintheiser.info, 59432,234,23
Imported Firm 2, Josh Fleck, josh@fleck.com,,20,
Imported Firm 3, David Peterson, david@peterson.com, 55407, 4000, 30
Imported Firm 4, Brian Terlson, brian.terlson@gmail.com, 98004,  210,23
"  
end 

# Participations are a bitch to get working in the factories, this eases the pain
def generate_participation(participant, survey)

  participation = Factory.build(:participation, 
    :participant => participant, 
    :survey      => survey, 
    :responses   => [])
    
  survey.questions.each do |question|  
    participation.responses << Factory.build(:numerical_response, :question => question, :response => 1)
  end  
  
  participation.save 
  
  participation
   
end
  
module AuthenticationRequiredSpecHelper

  # Get all actions for specified controller
  def get_all_actions(cont)
    c = Module.const_get(cont.to_s.pluralize.capitalize + "Controller")
    c.public_instance_methods(false).reject{ |action| ['rescue_action'].include?(action) }
  end

  # test actions fail if not logged in
  # opts[:exclude] contains an array of actions to skip
  # opts[:include] contains an array of actions to add to the test in addition
  # to any found by get_all_actions
  # someone clever with their meta-programming-fu could probably make this method not take
  # a controller, but it's good enough for now.
  
  def controller_actions_should_fail_if_not_logged_in(controller, opts={})
    except= opts[:except] || []
    actions_to_test= get_all_actions(controller).reject{ |a| except.include?(a) }
    actions_to_test += opts[:include] if opts[:include]
    actions_to_test.each do |a|
      get a
      response.should_not be_success
      response.should redirect_to(login_path)
    end
  end
  
end
