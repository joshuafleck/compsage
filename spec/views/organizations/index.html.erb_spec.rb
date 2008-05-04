require File.dirname(__FILE__) + '/../../spec_helper'

describe "/organizations/index" do
  before(:each) do
    # create organizations
    organization = mock_model(Organization)
    organization.stub!(:id).and_return("1")
    organization.stub!(:name).and_return("Huminsight")
    organization.stub!(:city).and_return("Minneapolis")
    organization.stub!(:state).and_return("Minnesota")
    organization.stub!(:location).and_return("Headquarters")
    organization.stub!(:contact_name).and_return("Josh Fleck")
    organization.stub!(:industry).and_return("Software")
    assigns[:organizations] = [organization]
    render 'organizations/index'
  end
  
  it "should show a search box" do
    #puts response.body
    response.should have_tag('form') do
      with_tag('input')
    end
  end
  
  it "should show a list or organizations" do
    response.should have_tag('tr#organization_1')
  end
    
end
