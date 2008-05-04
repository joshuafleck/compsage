require File.dirname(__FILE__) + '/../../spec_helper'

describe "/organizations/show" do
  before(:each) do
    # create organizations
    organization = mock_model(Organization)
    organization.stub!(:name).and_return("Huminsight")
    organization.stub!(:city).and_return("Minneapolis")
    organization.stub!(:state).and_return("Minnesota")
    organization.stub!(:location).and_return("Headquarters")
    organization.stub!(:contact_name).and_return("Josh Fleck")
    assigns[:organization] = organization
    
    render 'organizations/show'
  end
  
  it "should show the organization name" do
    response.should have_tag('h2',"Huminsight")   
  end
  
  it "should show the organization's location name" do
    response.should have_tag('p',"Location: Headquarters")
  end
  
  it "should show the organization's city" do
    response.should have_tag('p',"City: Minneapolis")
  end
  
  it "should show the organization's state" do
    response.should have_tag('p',"State: Minnesota")
  end
  
  it "should show the contacts at that organization" do
    response.should have_tag('p',"Contact Name: Josh Fleck")
  end
  
  it "should show the organization's logo if one exists" do
    pending
  end
  
  it "should show a generic logo if one doesn't exist" do
    pending
  end
  
  it "should show a link to invite this organization to a network" do
    pending
  end
  
  it "should show a link to invite this organization to a survey" do
    pending
  end
  
  #it "should list the organization's joined networks"
  #JF- Networks are no longer public
end
