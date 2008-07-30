require File.dirname(__FILE__) + '/../../spec_helper'

describe "/organizations/show" do
  before(:each) do
    # create organizations
    organization = mock_model(Organization)
    logo = mock_model(Logo, :public_filename => "blah")
    
    organization.stub!(:id).and_return("1")
    organization.stub!(:name).and_return("Huminsight")
    organization.stub!(:city).and_return("Minneapolis")
    organization.stub!(:state).and_return("Minnesota")
    organization.stub!(:location).and_return("Headquarters")
    organization.stub!(:contact_name).and_return("Josh Fleck")
    organization.stub!(:email).and_return("test")
    organization.stub!(:industry).and_return("Software")
    organization.stub!(:logo).and_return(logo)
    
    current_organization = mock_model(Organization)
    current_organization.stub!(:owned_networks).and_return([])
    current_organization.stub!(:sponsored_surveys).and_return(mock('surveys proxy', :running => []))
    
    assigns[:current_organization] = current_organization
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
    #puts response.body
    response.should have_tag('p',"Contact Name: Josh Fleck")
  end
  
  it "should show the organization's industry" do
    response.should have_tag('p',"Industry: Software")
  end
  
  it "should show the organization's logo if one exists" do
  	response.should have_tag('img[src=/images/test]')
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
  
end
