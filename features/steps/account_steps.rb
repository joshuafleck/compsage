Given /I am on the new account page/ do
  goto(new_account_url)
end

Given /I am on the edit account page/ do
  goto(edit_account_url)
end

Given /I have requested a password reset/ do
  @current_organization.create_reset_key_and_send_reset_notification
end

Given /I am on the reset password page/ do
  goto(reset_account_url(:key => @current_organization.reset_password_key))
end

When /I add an account/ do
    fills_in "Your Name", :with => "test name"
    fills_in "Zip", :with => "12345"
    fills_in "Password", :with => "test12"
    fills_in "Confirm password", :with => "test12"
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

When /I request a password reset/ do
    fills_in "Email Address", :with => @current_organization.email
    clicks_button 'Reset My Password'
end

When /I reset my password/ do
    fills_in "Password", :with => "reset password"
    fills_in "Password confirmation", :with => "reset password"
    clicks_button 'Reset My Password'
end


