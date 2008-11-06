Given /I am logged in/ do
  @current_organization = Factory.create(:organization)
  visits "/session/new"
  fills_in("Email", :with => @current_organization.email)
  fills_in("Password", :with => "test12")
  clicks_button "Log in"
  response.body.should_not =~ /Password/m
end
  

Given /I am on the new survey page/ do
  visits "/surveys/new"
end

