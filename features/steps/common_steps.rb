
def logout

  goto(root_url)
  
  if @testing_javascript then
    log_out = @browser.link(:name,'Log Out')
    log_out.click if log_out.exists?
  else      
    click_link "Log Out" if response.body =~ /Log Out/m
  end
  
end

def login

  email = @current_organization.email
  password = "test12"
  
  logout
  goto(new_session_url)
  
  if @testing_javascript then  
    @browser.text_field(:name,'email').value = email
    @browser.text_field(:name,'password').value = password
    @browser.button(:value,'Log in').click
  else
    fill_in("Email", :with => email)
    fill_in("Password", :with => password)
    click_button "Log in"
  end
  
end

def login_with_external_invitation
  
  logout
  goto(survey_login_url(:survey_id => @current_survey_invitation.survey.id, :key => @current_survey_invitation.key))
  
end

def goto(url)
  if @testing_javascript then  
    @browser.goto(url.sub('http://www.example.com',@base_url))
  else
    visit(url)
  end
end

Given /^I am testing javascript$/ do
  @testing_javascript = true
end

Given /^I am logged in$/ do
  login
end

Given /^I am logged in via survey invitation$/ do
  login_with_external_invitation
end

Given /^I am on the login page$/ do
  goto(new_session_url)
end

Given /^I own a network$/ do
  @network = Factory(:network, :owner => @current_organization)
end

Given "I am in a network" do
  @network = Factory(:network)
  @network.organizations << @current_organization
end

Given /^I am sponsoring a "([^\"]*)" survey$/ do |state|
  @survey = Factory("#{state}_survey".to_sym, :sponsor => @current_organization)
end

Given /^I am on the network page$/ do
  goto(network_url(@network))
end

Given /^there is an organization named "([^\"]*)"$/ do |name|
  create_organization(name)
end

Given /^there are organizations named ((?:\"[^\"]*\",? ?)+)$/ do |names|
  names = names.split(",").collect{|n| n.strip.gsub(/^"|"$/, "") }
  create_organization(names)
end
