require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/show" do

  before(:each) do
    # create organizations
    organization = mock_model(Organization)
    organization.stub!(:name).and_return("Huminsight")
    organization.stub!(:city).and_return("Minneapolis")
    organization.stub!(:state).and_return("Minnesota")
    organization.stub!(:location).and_return("Headquarters")
    organization.stub!(:contact_name).and_return("Josh Fleck")
    organization.stub!(:industry).and_return("Software")
    organization.stub!(:email).and_return("flec025@umn.edu")
    organization.stub!(:zip_code).and_return("55044")
    
    assigns[:organization] = organization
    
    render 'accounts/show'
  end
  
  it "should show the organization name" do
    response.should have_tag('p',"Name of Organization: Huminsight")   
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
  
  it "should display the email address" do
  	response.should have_tag('p',"Email Address: flec025@umn.edu")
  end
  
  it "should display the zip code" do
  	response.should have_tag('p',"Zip Code: 55044")
  end
  
  it "should display the image" do
  	pending
  end
  
  it "should have an edit account link" do
  	response.should have_tag('a[href=/account/edit]')
  end
     
end
