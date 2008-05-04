require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/show" do
  before(:each) do
    @organization_1 = mock_model(Organization, :name => "Org")
    @organization_2 = mock_model(Organization, :name => "Org 2")
    organizations = [@organization_1, @organization_2]
    organizations.stub!(:count).and_return(organizations.size)
    
    template.stub!(:current_organization).and_return(mock_model(Organization))
    
    @network = mock_model(Network,
      :name => "My Network",
      :description => "Description",
      :organizations => organizations,
      :owner => @organization_1,
      :owner_id => 1)
      
    assigns[:network] = @network
    
    render "networks/show"
  end
  
  it "should display the title" do
    response.should have_tag("h2", "My Network")
  end
  
  it "should display the description" do
    response.should have_tag("div", "Description")
  end
  
  it "should list the members of the network" do
    response.should have_tag("ul[id=organizations]")
  end
  
  it "should display the owner with a link to their organization's page" do
    response.should have_tag("a[href=#{organization_path(@organization_1)}]")
    response.should have_tag("a[href=#{organization_path(@organization_2)}]")
  end

  it "should have a link for leaving the network" do
    response.should have_tag("a[href=#{leave_network_path(@network)}]")
  end
end

describe "/networks/show when the organization is the owner of the network" do
  before(:each) do
    @organization_1 = mock_model(Organization, :name => "Org")
    @organization_2 = mock_model(Organization, :name => "Org 2")
    organizations = [@organization_1, @organization_2]
    organizations.stub!(:count).and_return(organizations.size)
    
    template.stub!(:current_organization).and_return(@organization_1)
    
    @network = mock_model(Network,
      :name => "My Network",
      :description => "Description",
      :organizations => organizations,
      :owner => @organization_1,
      :owner_id => @organization_1.id)
      
    assigns[:network] = @network
    
    render "networks/show"
  end
  
  it "should have a link for inviting organizations" do
    response.should have_tag("a[href=#{network_invitations_path(@network)}]")
  end
  
  it "should have a link for editing the network" do
    response.should have_tag("a[href=#{edit_network_path(@network)}]")
  end

end