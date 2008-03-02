require File.dirname(__FILE__) + '/../spec_helper'

module NetworkSpecHelper

  def valid_network_attributes
    {
      
    }
  end
  
end

describe Network, "that does not exist" do

  include NetworkSpecHelper

  before(:each) do
    @network = Network.new
  end  
  
  it "should have many invitations" do
  pending
  end
  
  it "should have many member organizations" do
  pending
  end
  
  it "should have an owner" do
  pending
  end
  
  it "should be invalid without a title" do
  pending
  end
  
  it "should be invalid with a title longer than 128 characters" do
  pending
  end  
  
  it "should be invalid with a description longer than 1024 characters" do
  pending
  end   
    
  it "should be invalid without an owner specified" do
  pending
  end

  it "should be valid with no description" do
  pending
  end   
   
  it "should be valid" do
  pending
  end  

end  

describe Network, "that does exist" do

  include NetworkSpecHelper

  before(:each) do
    @network = Network.new
    @network.attributes = valid_network_attributes
    @network.save
  end  
  
  after(:each) do
    @network.destroy
  end  
  
  it "should be public" do
  pending
  end  
       
end
 
