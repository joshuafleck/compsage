require File.dirname(__FILE__) + '/../spec_helper'

describe ExternalInvitation do

  before(:each) do
    @invitation = Factory.build(:external_invitation)
  end
  
  it "should be valid" do
    @invitation.should be_valid
  end  
     
  it "should be invalid without an email" do
    @invitation.email = nil
    @invitation.should have(1).errors_on(:email)
  end  
  
  it "should be invalid if the email is shorter than 6 characters or longer than 100 characters" do
    @invitation.email = "z"*5
    @invitation.should have(2).errors_on(:email)
    @invitation.email = "z"*101
    @invitation.should have(2).errors_on(:email)
  end    
  
  it "should be invalid if the email is not formatted correctly" do
    @invitation.email = "1234567"
    @invitation.should have(1).errors_on(:email)
  end    
  
  it "should be invalid without an organization name" do
    @invitation.organization_name = nil
    @invitation.should have(1).errors_on(:organization_name)
  end
  
  it "should be invalid if the organization name is shorter than 3 characters or longer than 100 characters" do
    @invitation.organization_name = "z"*2
    @invitation.should have(1).errors_on(:organization_name)
    @invitation.organization_name = "z"*101
    @invitation.should have(1).errors_on(:organization_name)
  end   
  
  it "should have an organization name and email" do
    @invitation.organization_name_and_email.should_not be_blank
  end    
    
  it "should have a key" do   
    @invitation.save!
    @invitation.key.should_not be_blank
    @invitation.destroy
  end

  it "should be invalid if the email address has opted out" do
    opt_out = Factory.create(:opt_out, :email => @invitation.email)

    @invitation.should_not be_valid
  end

end
