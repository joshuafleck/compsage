Given /I am on the new network page/ do
  visits new_network_url
end

Given /I am on the edit network page/ do
  visits edit_network_url(@network)
end

Given /I am on the show network page/ do
  visits network_url(@network)
end

Given /I am on the network index page/ do
  visits networks_url
end

Given /there is a network/ do
  @network = Factory.create(:network, :name => "Network 1", :description => "Network 1 Description")
end

Given /the network has members/ do
  @network.organizations << Factory.create(:organization, :name => "Organization 1", :contact_name => "Organization 1 contact")
  @network.organizations << Factory.create(:organization, :name => "Organization 2")  
end

Given /I own the network/ do
  @network.owner = @current_organization
  @network.save!
  @network.organizations << @current_organization
end

Given /I am invited to the network/ do
  @invitation = Factory.create(
    :network_invitation, 
    :inviter => @network.owner, 
    :invitee => @current_organization, 
    :network => @network)
end

Given /I am a member of the network/ do
  @network.organizations << @current_organization
end
