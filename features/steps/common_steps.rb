def logout
  visit(root_url)
  click_link "Log Out" if response_body =~ /Log Out/m
end

def login
  email = @current_organization.email
  password = "test12"
  
  logout
  visit(new_session_url)
  
  fill_in("email", :with => email)
  fill_in("password", :with => password)
  click_button "Log in"
end

def login_with_external_invitation
  logout
  @survey = @current_survey_invitation.survey
  visit survey_login_url(:survey_id => @survey.id, :key => @current_survey_invitation.key)
end

Given /^I am testing javascript$/ do
  self.dom_interface = :firewatir 
  self.dom_browser   = @browser
end

Given /^I am testing with (.*)$/ do |interface|
  self.dom_interface = interface.intern
  self.dom_browser   = @browser
end

Given /^I am logged in$/ do
  login
end

Given /^I am logged in via survey invitation$/ do
  login_with_external_invitation
end

Given /^I am on the login page$/ do
  visit(new_session_url)
end

Given "I am on the home page" do
  visit(root_url)
end

Given /^I own a network$/ do
  @network = Factory(:network, :owner => @current_organization, :name => "Owned network")
end

Given "I am in a network" do
  @network = Factory(:network, :name => "Belonged network")
  @network.organizations << @current_organization
end

Given /^I am sponsoring a ?"?([^\"]*)"? survey$/ do |state|
  state = 'pending' if state == ''
  @survey = Factory("#{state}_survey".to_sym, :sponsor => @current_organization)
end

Given /^I am on the network page$/ do
  visit(network_url(@network))
end

Given /^there is an organization named "([^\"]*)"$/ do |name|
  create_organization(name)
end

Given /^there are organizations named ((?:\"[^\"]*\",? ?)+)$/ do |names|
  names = names.split(",").collect{|n| n.strip.gsub(/^"|"$/, "") }
  create_organization(names)
end


When /^I click "([^\"]*)"$/ do |link_text|
  click_link link_text
end
