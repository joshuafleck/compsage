When "I am on the networks index" do
  visit add_subdomain(networks_url)
end

Given "I am on the new network page" do
  visit add_subdomain(new_network_url)
end

Given /^I am on the edit network page$/ do
  visit add_subdomain(edit_network_url(@network))
end

Given "I am invited to a network" do
  invitation = Factory(:network_invitation, :invitee => @current_organization)
  @network = invitation.network
  @network.name = "Invited network"
  @network.save!
end

Given "the network has members" do
  @network.organizations << Factory(:organization,:name => "network member")
end

When "I add a network" do
    fills_in "Network Name", :with => "My network"
    fills_in "Description", :with => "12345"
    clicks_button 'Create'  
end

When "I unsuccessfully add a network" do
    fills_in "Description", :with => "12345"
    clicks_button 'Create'  
end

When "I edit the network" do
    fills_in "Network Name", :with => "My network edited"
    clicks_button 'Update'  
end

When "the network survey has a question" do
    survey = @current_organization.sponsored_surveys.with_aasm_state(:pending).first    
    survey.questions << Factory(:question, :survey => survey)    
end

When "I unsuccessfully edit the network" do
    fills_in "Network Name", :with => ""
    clicks_button 'Update'  
end
