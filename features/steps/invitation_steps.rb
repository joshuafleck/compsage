Given /^I am on the survey invitations page$/ do
  goto(survey_invitations_url(@survey))
end

When "I type in an existing organization and select it from the dropdown" do
  create_organization("Existing Organization")
  @browser.text_field(:id, 'external_invitation_organization_name').set_without_blur("Ex")
  wait_for_ajax
  @browser.div(:id, 'search_results').link(:href, 'javascript:;').click
end

When /^I create an external invitation$/ do
  @browser.text_field(:id,'external_invitation_organization_name').value = 'external organization'
  @browser.text_field(:id,'external_invitation_email').value = 'test1@example.com'
  @browser.button(:value,'Add').click
end

Then /^I should be able to see the invitation$/ do
  wait_for_ajax
  assert(@browser.link(:class,'remove').exists?)
end
