require File.dirname(__FILE__) + '/../../spec_helper'

describe "/pending_accounts/new" do
  before(:each) do
  
    assigns[:pending_account] = mock_model(PendingAccount, 
      :organization_name => nil, 
      :contact_first_name => nil, 
      :contact_last_name => nil, 
      :email => nil, 
      :phone => nil, 
      :phone_extension => nil)
      
    render 'pending_accounts/new'
  end
  
  it "should show the new form" do
  	response.should have_tag("form")
  end
  
  it "should have a means for setting the organization name" do
    #puts response.body
  	response.should have_tag("input[id=pending_account_organization_name]")
  end
  
  it "should have a means for setting a contact first name" do    
  	response.should have_tag("input[id=pending_account_contact_first_name]")
  end
  
  it "should have a means for setting a contact last name" do
    response.should have_tag("input[id=pending_account_contact_last_name]")
  end
  
  it "should have a means for setting an email address" do
    response.should have_tag("input[id=pending_account_email]")
  end
  
  it "should have a means for setting an phone number" do
    response.should have_tag("input[id=pending_account_phone]")
  end 
  
  it "should have a means for setting an phone number extension" do
    response.should have_tag("input[id=pending_account_phone_extension]")
  end
  
  it "should have a captcha" do
    pending
  end
  
  it "should have a submit button" do
    response.should have_tag("input[type=submit]")
  end
  
  it "should have a cancel link, which links to the main index" do
    response.should have_tag("a[href=/]")
  end
  
end
