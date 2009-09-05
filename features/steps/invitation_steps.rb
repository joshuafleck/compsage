Given /^there is an organization named "([^\"]*)"$/ do |name|
  @organization = Factory(:organization, :name => name)
end

Given /^I am on the survey invitations page$/ do
  goto(survey_invitations_url(@survey))
end

When /^I create an invitation$/ do
  @browser.text_field(:id,'external_invitation_organization_name').value = 'invited organization'
  @browser.text_field(:id,'external_invitation_email').value = 'test1@example.com'
  @browser.button(:value,'Add').click
end

Then /^I should be able to see the invitation$/ do
  assert(@browser.link(:class,'remove').exists?)
end
