require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/edit" do

  before(:each) do
    organizations = [mock_model(Organization, :name => "Org"), mock_model(Organization, :name => "Org 2")]
    organizations.stub!(:count).and_return(organizations.size)
    
    template.stub!(:current_organization).and_return(mock_model(Organization))
    
    @network = mock_model(Network,
      :name => "My Network",
      :description => "Description",
      :organizations => organizations,
      :owner_id => 1)
      
    assigns[:network] = @network
    
    render 'networks/edit'
  end
  
  it "should show the edit form" do
    response.should have_tag("form")
  end
  
  it "should have a means for editing the name" do
    response.should have_tag("input[id=network_name]")
  end
  
  it "should have a means for editing the description" do
    response.should have_tag("textarea[id=network_description]")
  end
 
  it "should have a means for changing the owner" do
    response.should have_tag("ul[id=organizations]") do
      with_tag("input[type=radio]")
    end
  end
  
  it "should have a submit button" do
    response.should have_tag("input[type=submit]")
  end
  
  it "should have a cancel link that links to the network show page" do
    response.should have_tag("a[href=#{networks_path}]", "Cancel")
  end
end
