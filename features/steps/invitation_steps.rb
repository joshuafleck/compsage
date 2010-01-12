Given /^I am on the survey invitations page$/ do
  visit add_subdomain(survey_invitations_url(@survey))
end

Given "I have created a survey invitation" do
  Factory(:survey_invitation, :survey => @survey) 
end

When "I type in an existing organization and select it from the dropdown" do
  create_organization "Existing Organization"
  fill_in 'external_invitation_organization_name', :with => 'Ex', :method => :set_without_blur
  wait_for_javascript
  div('search_results').link(:href, '#').click
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

When /^I enter an organization name$/ do
  fill_in "organization_name", :with => "ASDF", :method => :set_without_blur
  select "10", :from => "organization_location"
  wait_for_javascript 
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

Then "I should see an invitation success message" do
  wait_for_javascript
  response_body.should =~ /Invitation sent to/
end

Then "I should see the survey sponsor in the invitation list" do
  get_element_by_xpath("id('invitations')/li/a").text.should include(@survey.sponsor.name)
end

Then "I should see no association members" do
  assert(get_element_by_xpath("id('association_organizations')/li").nil?)
end
