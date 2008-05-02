# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

include AuthenticatedTestHelper

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
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
    :password => 'test1',
    :password_confirmation => 'test1',
    :name => 'Denarius',
    :contact_name => 'Andersen Cooper',
    :city => 'New York',
    :location => 'Eastern Division',
    :state => 'New York'
  }
end

def organization_mock 
  mock_model(
      Organization, 
      valid_organization_attributes)

end
  
def valid_survey_attributes
  {
    :end_date => Date.new
  }
end

def survey_mock 
  mock_model(
      Survey, 
      valid_survey_attributes)

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
