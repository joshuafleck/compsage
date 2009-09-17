Given "I am on the organization page" do
  @organization = Factory(:organization, :name => "Phillip McCracken")
  visit organization_url(@organization)
end

Given "I am on the organization page of a survey sponsor" do
  visit organization_url(@current_survey_invitation.survey.sponsor)
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
