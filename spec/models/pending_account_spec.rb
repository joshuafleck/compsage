require File.dirname(__FILE__) + '/../spec_helper'

module PendingAccountSpecHelper

  def valid_pending_account_attributes
    {
      :email => 'brian.terlson@gmail.com',
      :organization_name => 'Testing Name',
      :contact_first_name => 'Brian',
      :contact_last_name => 'Terlson',
      :phone => '763.498.3633'
    }
  end
  
end

describe PendingAccount do

  include PendingAccountSpecHelper

  before(:each) do
    @pending_account = PendingAccount.new
  end  
  
  it "should be invalid without an email" do
    @pending_account.attributes = valid_pending_account_attributes.except(:email)
    @pending_account.should have_at_least(1).error_on(:email)
  end
   
  it "should be invalid without an organization name" do
    @pending_account.attributes = valid_pending_account_attributes.except(:organization_name)
    @pending_account.should have_at_least(1).error_on(:organization_name)
  end
     
  it "should be invalid without a contact first name" do
    @pending_account.attributes = valid_pending_account_attributes.except(:contact_first_name)
    @pending_account.should have_at_least(1).error_on(:contact_first_name)
  end
    
  it "should be invalid without a contact last name" do
    @pending_account.attributes = valid_pending_account_attributes.except(:contact_last_name)
    @pending_account.should have_at_least(1).error_on(:contact_last_name)
  end
   
  it "should be invalid without a phone number" do
    @pending_account.attributes = valid_pending_account_attributes.except(:phone)
    @pending_account.should have_at_least(1).error_on(:phone)
  end
 
  it "should be invalid when the email is greater than 100 characters in length" do
    @pending_account.attributes = valid_pending_account_attributes.with(:email => 'a'*100 + '@gmail.com')
    @pending_account.should have(1).error_on(:email)
  end
 
  it "should be invalid when the email not a valid email address" do
    @pending_account.attributes = valid_pending_account_attributes.with(:email => 'testing.com')
    @pending_account.should have(1).error_on(:email)
    @pending_account.email = 'bleh@.com'
    @pending_account.should have(1).error_on(:email)
    @pending_account.email = 'asdf@asdf'
    @pending_account.should have(1).error_on(:email)
    @pending_account.email = 'xxxs'
    @pending_account.should have(2).error_on(:email)
  end
  
  it "should be invalid when the organization name is less than 3 characters in length" do
    @pending_account.attributes = valid_pending_account_attributes.with(:organization_name => 'as')
    @pending_account.should have(1).error_on(:organization_name)
  end
 
  it "should be invalid when the organization name is greater than 100 characters in length" do
    @pending_account.attributes = valid_pending_account_attributes.with(:organization_name => 'a' * 101)
    @pending_account.should have(1).error_on(:organization_name)
  end
   
  it "should be invalid when the contact first name is less than 2 characters in length" do
    @pending_account.attributes = valid_pending_account_attributes.with(:contact_first_name => 'a')
    @pending_account.should have(1).error_on(:contact_first_name)
  end
 
  it "should be invalid when the contact first name is greater than 100 characters in length" do
    @pending_account.attributes = valid_pending_account_attributes.with(:contact_first_name => 'a'*101)
    @pending_account.should have(1).error_on(:contact_first_name)
  end
 
  it "should be invalid when the contact last name is less than 3 characters in length" do
    @pending_account.attributes = valid_pending_account_attributes.with(:contact_last_name => 'a')
    @pending_account.should have(1).error_on(:contact_last_name)
  end
 
  it "should be invalid when the contact last name is greater than 100 characters in length" do
    @pending_account.attributes = valid_pending_account_attributes.with(:contact_last_name => 'a'*101)
    @pending_account.should have(1).error_on(:contact_last_name)
  end
 
  it "should be invalid when the phone number is greater than 10 numbers" do
    @pending_account.attributes = valid_pending_account_attributes.with(:phone => '212123912329')
    @pending_account.should have(1).error_on(:phone)
  end
    
  it "should be invalid when the phone number extension is greater than 6 numbers" do
    @pending_account.attributes = valid_pending_account_attributes.with(:phone_extension => '3993235')
    @pending_account.should have(1).error_on(:phone_extension)
  end
  
  it "should be valid" do
    @pending_account.attributes = valid_pending_account_attributes
    @pending_account.should be_valid
  end 
  
  it "should strip out punctuation from the phone number before validating" do
    @pending_account.attributes = valid_pending_account_attributes.with(:phone => '124.212.5212')
    @pending_account.valid?
    @pending_account.phone.should == '1242125212'
  end

  it "should send out a creation email when saved" do
    @pending_account.attributes = valid_pending_account_attributes
    Notifier.should_receive(:deliver_pending_account_creation_notification).and_return(true)
    @pending_account.save!
  end
end

describe PendingAccount, "being approved" do
  include PendingAccountSpecHelper

  before do
    @pending_account = PendingAccount.create(valid_pending_account_attributes)
  end

  it "should send out a notification email" do 
    Notifier.should_receive(:deliver_pending_account_approval_notification).and_return(true)
    @pending_account.approve
  end
end
