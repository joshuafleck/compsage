require File.dirname(__FILE__) + '/../spec_helper'

module PendingAccountSpecHelper

  def valid_pending_account_attributes
    {
      
    }
  end
  
end

describe PendingAccount do

  include PendingAccountSpecHelper

  before(:each) do
    @pending_account = PendingAccount.new
  end  
  
  it "should be invalid without an email" do
  	pending
  end
   
  it "should be invalid without a name" do
  	pending
  end
     
  it "should be invalid without a contact first name" do
  	pending
  end
    
  it "should be invalid without a contact last name" do
  	pending
  end
   
  it "should be invalid without a phone number" do
  	pending
  end
  
  it "should be invalid when the email is less than 3 characters in length" do
  	pending
  end
 
  it "should be invalid when the email is greater than 100 characters in length" do
  	pending
  end
 
  it "should be invalid when the email not a valid email address" do
  	pending
  end
  
  it "should be invalid when the name is less than 3 characters in length" do
  	pending
  end
 
  it "should be invalid when the name is greater than 100 characters in length" do
  	pending
  end
   
  it "should be invalid when the contact first name is less than 3 characters in length" do
  	pending
  end
 
  it "should be invalid when the contact first name is greater than 100 characters in length" do
  	pending
  end
 
  it "should be invalid when the contact last name is less than 3 characters in length" do
  	pending
  end
 
  it "should be invalid when the contact last name is greater than 100 characters in length" do
  	pending
  end
 
  it "should be invalid when the phone number is greater than 10 numbers" do
  	pending
  end
    
  it "should be invalid when the phone number extension is greater than 4 numbers" do
  	pending
  end
  
  it "should be valid" do
  	pending
  end 
  
  it "should strip out punctuation from the phone number before saving" do
  	pending
  end

end  

describe PendingAccount, "that does exist" do

  include PendingAccountSpecHelper

  before(:each) do
    @pending_account = PendingAccount.new
    @pending_account.attributes = valid_pending_account_attributes
    @pending_account.save
  end  
  
  after(:each) do
    @pending_account.destroy
  end  
     
end
 
