require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/index" do

  before(:each) do
    owner = mock_model(Organization, :name => "Edgecomm")
    template.stub!(:current_organization).and_return(mock_model(Organization))
    
    organizations = [owner]
    organizations.stub!(:count).and_return(2)
    
    @network_1 = mock_model(Network,
      :name => "My Network 1",
      :owner => owner,
      :owner_id => owner.id,
      :description => "Great network!",
      :organizations => organizations)
    @network_2 = mock_model(Network,
      :name => "My Network 2",
      :owner => owner,
      :owner_id => owner.id,
      :description => "OK network.",
      :organizations => organizations)
    
    assigns[:networks] = [@network_1, @network_2]
    render 'networks/index'
  end
  
  it "should show the list of networks" do
    response.should have_tag("#networks")
  end
  
  it "should display the name of each network" do
    response.should have_tag("div", "My Network 1")
    response.should have_tag("div", "My Network 2")
  end
  
  it "should display the number of members for each network" do
    response.should have_tag("a", "2 Members")
  end
  
  it "should have a link to show each network" do
    response.should have_tag("a[href=#{network_path(@network_1)}]")
    response.should have_tag("a[href=#{network_path(@network_2)}]")
  end

  it "should have a link for creating a new network" do
    response.should have_tag("a[href=#{new_network_path}]")
  end
  
  it "should have a link for leaving each network" do
     response.should have_tag("a[href=#{leave_network_path(@network_1)}]")
     response.should have_tag("a[href=#{leave_network_path(@network_2)}]")
  end
   
  it "should not have a link for editing the network" do
    response.should_not have_tag("a[href=#{edit_network_path(@network_1)}]")
    response.should_not have_tag("a[href=#{edit_network_path(@network_2)}]")
  end
  
  it "should not have a link for inviting new members" do
    response.should_not have_tag("a[href=#{network_invitations_path(@network_1)}]")
    response.should_not have_tag("a[href=#{network_invitations_path(@network_2)}]")
  end
  
end

describe "/networks/index when a network is owned by the organization" do
  before(:each) do
    owner = mock_model(Organization, :name => "Edgecomm")
    template.stub!(:current_organization).and_return(owner)
    
    organizations = [owner]
    organizations.stub!(:count).and_return(2)
    
    @network_1 = mock_model(Network,
      :name => "My Network 1",
      :owner => owner,
      :owner_id => owner.id,
      :description => "Great network!",
      :organizations => organizations)
    @network_2 = mock_model(Network,
      :name => "My Network 2",
      :owner => mock_model(Organization),
      :owner_id => owner.id,
      :description => "OK network.",
      :organizations => organizations)
    
    assigns[:networks] = [@network_1, @network_2]
    render 'networks/index'
  end
  
  it "should have a link to edit the network" do
    response.should have_tag("a[href=#{edit_network_path(@network_1)}]")
    response.should have_tag("a[href=#{edit_network_path(@network_2)}]")
  end
  
  it "should have a link for inviting organizations to the network" do
    response.should have_tag("a[href=#{network_invitations_path(@network_1)}]")
    response.should have_tag("a[href=#{network_invitations_path(@network_2)}]")
  end
  
end