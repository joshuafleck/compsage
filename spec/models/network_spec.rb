require File.dirname(__FILE__) + '/../spec_helper'

module NetworkSpecHelper

  def valid_network_attributes
    {
      
    }
  end
  
end

describe Network, "class relationships" do

  it "has many network invitations" do
  #future code here pending review
  end
  
  it "has many member organizations" do
  #future code here pending review
  end
  
  it "has an owner" do
  #future code here pending review
  end
  
end  

describe Network, "creating/updating" do

  include NetworkSpecHelper

  before(:each) do
    @network = Network.new
  end  
  
  it "requires a title" do
  #future code here pending review
  end
  
  it "does not allow a title longer then 128 characters" do
  #future code here pending review
  end  
  
  it "does not allow a description longer then 1024 characters" do
  #future code here pending review
  end   

  it "allows a nil description" do
  #future code here pending review
  end   
    
  it "requires an owner on create" do
  #future code here pending review
  end
  
  it "does not require an owner on update" do
  #future code here pending review
  end  
  
end

describe Network, "destruction" do

  include NetworkSpecHelper

  before(:each) do
    @network = Network.new
  end  
    
  it "destroys related invitations on destroy" do
  #future code here pending review
  end  
  
end 