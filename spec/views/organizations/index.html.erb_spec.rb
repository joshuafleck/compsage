require File.dirname(__FILE__) + '/../../spec_helper'

describe "/organizations/index" do
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
    assigns[:organizations] = [organization]
    
    render 'organizations/index'
  end
  
  it "should show a search box" do
    #puts response.body
    response.should have_tag('form') do
      with_tag('input')
    end
  end
  
  it "should show the list of organizations" do
    response.should have_tag("#organizations")
  end
  
  it "should display the name of each organization" do
    response.should have_tag("div", "Huminsight")
  end
  
  it "should display the logo of each organization" do
    response.should have_tag("div[class=organization_logo]")
  end
  
  it "should have links for inviting organizations to a network" do
    pending
  end
  
  it "should have links for inviting organizations to a survey" do
    pending
  end
    
end
