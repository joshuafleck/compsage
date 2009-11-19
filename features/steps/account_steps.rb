Given /I am on the new account page/ do
  visit add_subdomain(new_account_url)
end

Given /I am on the edit account page/ do
  visit add_subdomain(edit_account_url)
end

Given /I have requested a password reset/ do
  @current_organization.create_reset_key_and_send_reset_notification
end

Given /the password reset request is expired/ do
  @current_organization.reset_password_key_expires_at = Time.now - 1.minute
  @current_organization.save!
end

Given /I am on the reset password page/ do
  visit add_subdomain(reset_account_url(:key => @current_organization.reset_password_key))
end

Given "I am logged in via network invitation" do
  invitation = Factory(:external_network_invitation)
  visit add_subdomain(new_account_path(:key => invitation.key))
end

Given "I am logged in via pending account" do
  invitation = Factory(:pending_account)
  visit add_subdomain(new_account_path(:key => invitation.key))
end

When /I add an account/ do
    fills_in "Your Name", :with => "test name"
    fills_in "Zip", :with => "12345"
    fills_in "Password", :with => "test12"
    fills_in "Confirm password", :with => "test12"
    check "I have read and understand the Terms of Use"
    clicks_button 'Sign Up'
end

When /I unsuccessfully add an account/ do
    fills_in "Your Name", :with => "test name"
    fills_in "Zip", :with => "12345"
    fills_in "Password", :with => "test12"
    fills_in "Confirm password", :with => "bad boy"
    clicks_button 'Sign Up'
end

When /I edit the account/ do
    fills_in "Email address", :with => "test@example.com"
    fills_in "Your Name", :with => "test name"
    fills_in "Zip", :with => "12345"
    fills_in "Password", :with => "test123"
    fills_in "Confirm password", :with => "test123"
    clicks_button 'Update'
end

When /I unsuccessfully edit the account/ do
    fills_in "Email address", :with => "test@example.com"
    fills_in "Your Name", :with => "test name"
    fills_in "Zip", :with => "12345"
    fills_in "Password", :with => "test123"
    fills_in "Confirm password", :with => "bad boy"
    clicks_button 'Update'
end

When /I request a password reset/ do
    fills_in "Email Address", :with => @current_organization.email
    clicks_button 'Reset My Password'
end

When /I unsuccuessfully request a password reset/ do
    fills_in "Email Address", :with => "junk"
    clicks_button 'Reset My Password'
end

When /I reset my password/ do
    fills_in "Password", :with => "reset password"
    fills_in "Password confirmation", :with => "reset password"
    clicks_button 'Reset My Password'
end

When /I unsuccessfully reset my password/ do
    fills_in "Password", :with => "reset password"
    fills_in "Password confirmation", :with => "bad boy"
    clicks_button 'Reset My Password'
end

