def association_member_logout
  visit add_subdomain(sign_in_association_member_url)
  click_link "Log Out" if response_body =~ /Log Out/m
end

def association_member_sign_in(email)
  association_member_logout
  visit add_subdomain(sign_in_association_member_url)

  password = "test12"
  fill_in("email", :with => email)
  fill_in("password", :with => password) 
  fill_in("email1", :with => email)
  fill_in("password1", :with => password) 
end

def uninitialized_association_member_sign_in

  current_uninitialized_organization = Factory.create(:uninitialized_association_member)
  @current_association.organizations << current_uninitialized_organization  
 
  email = current_uninitialized_organization.email
  association_member_sign_in(email)

end

def initialized_association_member_sign_in

  @current_association.organizations << @current_organization  
 
  email = @current_organization.email
  association_member_sign_in(email)

end

Given /^there is an uninitialized association member$/ do
  uninitialized_association_member_sign_in
end

Given /^there is an initialized association member$/ do
  initialized_association_member_sign_in
end

When /^I log into the association$/ do
  click_button "Log in"  
end

When /^I sign up into the association$/ do
  click_button "Sign Up"
end

When /^I fill in the confirmation$/ do
  fill_in("password_confirmation", :with => "test12") 
end
