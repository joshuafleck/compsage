Given /I am on the new pending account page/ do
  visit signup_url
end

When /^I add a pending account$/ do
    fills_in "Name of Your Organization", :with => "test organization"
    fills_in "First Name", :with => "test first name"
    fills_in "Last Name", :with => "test last name"
    fills_in "Email", :with => "test@test.com"
    fills_in "phone", :with => "1234567890"
    clicks_button 'Signup'
end

When /^I unsuccessfully add a pending account$/ do
    fills_in "Name of Your Organization", :with => "test organization"
    clicks_button 'Signup'
end
