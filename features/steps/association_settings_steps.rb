def association_login
  email = @current_association_by_owner.owner_email
  password = "test12"

  logout
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

Given /^I have created a standard PDQ$/ do
  Factory.create(:predefined_question, :name => "My Current PDQ", :association_id => @current_association_by_owner.id)
end


When /^I enter the predefined question information$/ do
  fill_in("predefined_question_name", :with => "My PDQ")
  fill_in("question_text", :with => "My question text.")
end

When /^I confirm I want to delete the predefined question$/ do
  @browser.startClicker("OK")
  click_link "delete_link"
end
