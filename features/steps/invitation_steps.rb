Given /^I am on the survey invitations page$/ do
  goto(survey_invitations_url(@survey))
end

Given "I have created a survey invitation" do
  Factory(:survey_invitation, :survey => @survey) 
end

When "I type in an existing organization and select it from the dropdown" do
  create_organization "Existing Organization"
  @browser.text_field(:id, 'external_invitation_organization_name').set_without_blur("Ex")
  wait_for_ajax
  @browser.div(:id, 'search_results').link(:href, 'javascript:;').click
end

When "I type in an existing organization and invite them" do
  org = create_organization("Existing Organization")
  @browser.text_field(:id, 'external_invitation_organization_name').value = org.name
  @browser.text_field(:id, 'external_invitation_email').value = org.email
  @browser.button(:value, 'Add').click
end

When "I type in an invalid invitation" do
  @browser.text_field(:id, 'external_invitation_organization_name').value = "hurrrr"
  @browser.button(:value, 'Add').click
end

When "I invite the network" do
  @browser.link(:id, "network_#{@network.id}_invite").click
end

When /^I create an external invitation$/ do
  @browser.text_field(:id,'external_invitation_organization_name').value = 'external organization'
  @browser.text_field(:id,'external_invitation_email').value = 'test1@example.com'
  @browser.button(:value,'Add').click
end

When "I send a duplicate invitation" do
  @browser.text_field(:id,'external_invitation_organization_name').value = 'external organization'
  @browser.text_field(:id,'external_invitation_email').value = 'test1@example.com'
  @browser.button(:value,'Add').click

  @browser.text_field(:id,'external_invitation_organization_name').value = 'external organization'
  @browser.text_field(:id,'external_invitation_email').value = 'test1@example.com'
  @browser.button(:value,'Add').click
end

When "I remove the invitation" do
  @browser.link(:class, 'remove').click
end

Then /^I should see the invitation$/ do
  wait_for_javascript
  assert(@browser.link(:class,'remove').exists?)
end

Then "I should not see the invitation" do
  wait_for_javascript
  assert(!@browser.link(:class,'remove').exists?)
end

Then "I should see an error message" do
  wait_for_javascript
  assert(@browser.div(:id, 'errorExplanation').exists?)
end
