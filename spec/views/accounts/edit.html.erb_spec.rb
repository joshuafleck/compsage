require File.dirname(__FILE__) + '/../../spec_helper'

describe "accounts/edit" do

  before(:each) do
    assigns[:organization] = mock_model(Organization, 
      :name => nil, 
      :contact_name => nil, 
      :email => nil, 
      :location => nil, 
      :city => nil, 
      :state => nil, 
      :zip_code => nil, 
      :industry => nil, 
      :password => nil, 
      :password_confirmation => nil,
      :logo => nil,
      :image_temp => nil)
    render 'accounts/edit'
  end

  it "should show the edit form" do
  	response.should have_tag("form")
  end
  
  it "should have a means for allowing the organization to input its email address" do
    #puts response.body
  	response.should have_tag("input[id=organization_email]")
  end
  
  it "should have a means for allowing the organization to input its password"	 do
  	response.should have_tag("input[id=organization_password]")
  end
  
  it "should have a means for allowing the organization to input its password confirmation"	 do
  	response.should have_tag("input[id=organization_password_confirmation]")
  end
  
  it "should have a means for allowing the organization to input its location" do
  	response.should have_tag("input[id=organization_location]")
  end
  
  it "should have a means for allowing the organization to input its city" do
  	response.should have_tag("input[id=organization_city]")
  end
  
  it "should have a means for allowing the organization to input its zip code" do
  	response.should have_tag("input[id=organization_zip_code]")
  end  
  
  it "should have a means for allowing the organization to select its state" do
  	response.should have_tag("select[id=organization_state]")
  end
  
  it "should have a means for allowing the organization to select its industry" do
  	response.should have_tag("select[id=organization_industry]")
  end  
  
  it "should have a means for allowing the organization to input its contact name" do
  	response.should have_tag("input[id=organization_contact_name]")
  end
  
  it "should have a means for allowing the organization to input its image" do
    pending
    #Requires upload ability
  	response.should have_tag("input[id=organization_logo]")
  end
  
  it "should have a submit button" do
  	response.should have_tag("input[type=submit]")
  end
  
  it "should have a cancel link that links back to the account page" do
  	response.should have_tag("a[href=#{account_path}]")
  end
  
end
