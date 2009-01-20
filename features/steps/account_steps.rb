Given /I am on the new account page/ do
  visits new_account_url
end

Given /I am on the edit account page/ do
  visits edit_account_url
end

Given /I am on the login page/ do
  visits new_session_url
end

Given /I am on the reset password page/ do  
  @current_organization = Organization.find_by_email("test@test.com")
  visits reset_account_url(:key => @current_organization.reset_password_key)
end

Given /there is an organization/ do
  @current_organization = Factory.create(:organization, :name => "Organization 0", :email => "test@test.com")
end
