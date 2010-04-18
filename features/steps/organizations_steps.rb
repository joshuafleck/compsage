Given "I am on the organization page" do
  @organization = Factory(:organization, :name => "Phillip McCracken")
  visit add_subdomain(organization_url(@organization))
end

Given "I am on the organization page of a survey sponsor" do
  visit add_subdomain(organization_url(@current_survey_invitation.survey.sponsor))
end

Given "there is a survey sponsored by a pending organization" do
  @pending_organization = Factory(:pending_organization)
  @survey = Factory(:running_survey, :sponsor => @pending_organization)
end

Given "I am a member of a network owned by a pending organization" do
  @pending_organization = Factory(:pending_organization)
  @network = Factory(:network, :owner => @pending_organization)
  @network.organizations << @current_organization
end

When "I report this user" do
  @browser.startClicker("OK")
  click_link "report_user"
end

When "I invite the organization to a survey" do
  select @survey.id.to_s, :from => 'survey_id'
  click_button "Send"
  wait_for_javascript
end

When "I invite the organization to a network" do
  select @network.id.to_s, :from => 'network_id'
  click_button "Send"
  wait_for_javascript
end

Then /^I should see "([^\"]*)" success message$/ do |type|
  assert(!get_element_by_xpath("//span[@id='#{type}_success']").nil?)
end

Then /^I should see "([^\"]*)" error message$/ do |type|
  wait_for_javascript
  assert(get_element_by_xpath("//span[@id='#{type}_error_content']").nil?)
end
