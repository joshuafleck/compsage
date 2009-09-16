Given /^I am on the survey invitations page$/ do
  visit survey_invitations_url(@survey)
end

Given "I have created a survey invitation" do
  Factory(:survey_invitation, :survey => @survey) 
end

When "I type in an existing organization and select it from the dropdown" do
  create_organization "Existing Organization"
  fill_in 'external_invitation_organization_name', :with => 'Ex', :method => :set_without_blur
  wait_for_ajax
  div('search_results').link(:href, 'javascript:;').click
end

When "I type in an existing organization and invite them" do
  org = create_organization("Existing Organization")
  fill_in 'external_invitation_organization_name', :with => org.name
  fill_in 'external_invitation_email', :with => org.email

  click_button('Add')
end

When "I type in an invalid invitation" do
  fill_in 'external_invitation_organization_name', :with => "hurrrr"
  click_button('Add')
end

When "I invite the network" do
  click_link("network_#{@network.id}_invite")
end

When /^I create an external invitation$/ do
  fill_in 'external_invitation_organization_name', :with => 'external organization'
  fill_in 'external_invitation_email', :with => 'test1@example.com'

  click_button('Add')
end

When "I send a duplicate invitation" do
  fill_in 'external_invitation_organization_name', :with => 'external organization'
  fill_in 'external_invitation_email', :with => 'test1@example.com'
  click_button('Add')

  fill_in 'external_invitation_organization_name', :with => 'external organization'
  fill_in 'external_invitation_email', :with => 'test1@example.com'
  click_button('Add')
end

When "I remove the invitation" do
  click_link('remove')
end

Then "I should see the invitation" do
  wait_for_javascript
  assert(!get_element_by_xpath("//a[@class='remove']").nil?)
end

Then "I should not see the invitation" do
  wait_for_javascript
  assert(get_element_by_xpath("//a[@class='remove']").nil?)
end

Then "I should see an error message" do
  wait_for_javascript
  div('errorExplanation').exists?
end
