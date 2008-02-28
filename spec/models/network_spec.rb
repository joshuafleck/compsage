require File.dirname(__FILE__) + '/../spec_helper'

module NetworkSpecHelper

  def valid_network_attributes
    {
      
    }
  end
  
end

describe Network, "that does not exist" do

  it "has many network invitations" do
  #future code here pending review
  end
  
  it "has many member organizations" do
  #future code here pending review
  end
  
  it "has an owner" do
  #future code here pending review
  end
  
  it "should be invalid without a title" do
  #future code here pending review
  end
  
  it "should be invalid with a title longer than 128 characters" do
  #future code here pending review
  end  
  
  it "should be invalid with a description longer than 1024 characters" do
  #future code here pending review
  end   
    
  it "should be invalid without an owner specified" do
  #future code here pending review
  end

  it "should be valid with a nil description" do
  #future code here pending review
  end   
   
end  

describe Network, "that does exist" do

  include NetworkSpecHelper

  before(:each) do
    @network = Network.new
  end  
  
  it "should be valid on create" do
  #future code here pending review
  end  
 
  it "should not require an owner on update" do
  #future code here pending review
  end  
 
  it "should be public by default" do
  #future code here pending review
  end  
       
end
 
