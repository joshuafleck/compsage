def association_logout
  visit add_subdomain(new_association_session_url)
  click_link "Log Out" if response_body =~ /Log Out/m
end

def association_login
  email = @current_association_by_owner.contact_email
  password = "test12"

  association_logout
  visit add_subdomain(new_association_session_url)

  fill_in("email", :with => email)
  fill_in("password", :with => password)
  click_button "Log in"
end

Given /^I am logged in as an association owner$/ do
  association_login
end

Given /^I am on the settings page$/ do
  visit add_subdomain(association_settings_url)
end

Given /^I am on the members page$/ do
  visit add_subdomain(association_members_url)
end

Given /^I have created a standard PDQ$/ do
  Factory.create(:predefined_question, :name => "My Current PDQ", :association_id => @current_association_by_owner.id)
end

Given /^I have added firms to my association$/ do
  click_link "add"
  fill_in("organization_name", :with => "Firm")
  fill_in("organization_email", :with => "firm@fake.com")
  fill_in("organization_zip_code", :with => "12345")
  click_button "commit"
end

When /^I enter the predefined question information$/ do
  fill_in("predefined_question_name", :with => "My PDQ")
  fill_in("question_text", :with => "My question text.")
end

When /^I confirm I want to delete the predefined question$/ do
  @browser.startClicker("OK")
  click_link "delete_link"
end

When /^I enter "([^\"]*)" firm information$/ do |how|
  fill_in("organization_name", :with => "Firm")
  if how == "good" then
    fill_in("organization_email", :with => "firm@fake.com")
  else
    fill_in("organization_email", :with => "derrrr")
  end
  fill_in("organization_zip_code", :with => "12345")
end

When /^I press the remove button$/ do
  @browser.startClicker("OK")
  click_button "remove"
end

When /^I click the firm link$/ do
  click_link "edit_#{@current_association_by_owner.organizations.first.id}"
end


