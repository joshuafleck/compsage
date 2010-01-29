def logout
  visit add_subdomain(root_url)
  click_link "Log Out" if response_body =~ /Log Out/m
end

def login
  email = @current_organization.email
  password = "test12"
  
  logout
  visit add_subdomain(new_session_url)
  
  fill_in("email", :with => email)
  fill_in("password", :with => password)
  click_button "Log in"
end

def login_with_external_invitation
  logout
  @survey = @current_survey_invitation.survey
  visit add_subdomain(survey_login_url(:survey_id => @survey.id, :key => @current_survey_invitation.key))
end

def create_survey(state, sponsor)
  state = 'pending' if state == ''
  Factory("#{state}_survey".to_sym, :sponsor => sponsor)
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
  visit add_subdomain(new_session_url)
end

Given "I am on the home page" do
  visit add_subdomain(root_url)
end

Given /^I own a network$/ do
  @network = Factory(:network, :owner => @current_organization, :name => "Owned network")
end

Given "I am in a network" do
  @network = Factory(:network, :name => "Belonged network")
  @network.organizations << @current_organization
end

Given /^I am sponsoring a ?"?([^\"]*)"? survey$/ do |state|
  @survey = create_survey(state, @current_organization)
end

Given /^I am participating in a ?"?([^\"]*)"? survey$/ do |state|
  @survey = create_survey(state, Factory(:organization))
  participation = Factory.build(:participation, :participant => @current_organization, :survey => @survey, :responses => [])
  @survey.questions.each do |question|  
    participation.responses << Factory.build(:numerical_response, :question => question, :response => 1)
  end  
  participation.save  
end

Given /^I am on the network page$/ do
  visit add_subdomain(network_url(@network))
end

Given /^there is an organization named "([^\"]*)"$/ do |name|
  create_organization(name)
end

Given /^I belong to an association with members$/ do
  #Add an organization which has a distinct name
  o = Factory(:organization, :name => "Existing Organization")
  o.save!
  @current_association.organizations << o
  
  #Add ten generic organizations
  @current_association.organizations << @current_organization
  10.times do
    o = Factory(:organization)
    o.save!
    @current_association.organizations << o
  end
  
  @association_organizations = @current_association.organizations
  invitees = @survey.invitees.all
  @association_organizations.reject!{|o| invitees.include?(o) }
end

Given /^there are organizations named ((?:\"[^\"]*\",? ?)+)$/ do |names|
  names = names.split(",").collect{|n| n.strip.gsub(/^"|"$/, "") }
  create_organization(names)
end

When /^I click "([^\"]*)"$/ do |link_text|
  click_link link_text
end
