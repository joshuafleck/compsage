require File.dirname(__FILE__) + '/../spec_helper'

module NetworkSpecHelper

  def valid_network_attributes
    {
      :name => "My Network",
      :description => "This is my network, for networking.",
      :owner => organization_mock
    }
  end
  
end

describe Network do

  include NetworkSpecHelper

  before(:each) do
    @network = Network.new
  end  
  
  it "should have many invitations" do
    Network.reflect_on_association(:invitations).should_not be_nil
  end
  
  it "should have many external invitations" do
    Network.reflect_on_association(:external_invitations).should_not be_nil
  end
  
  it "should have many member organizations" do
    Network.reflect_on_association(:organizations).should_not be_nil
  end
  
  it "should have an owner" do
    Network.reflect_on_association(:owner).should_not be_nil
  end
  
  it "should be invalid without a title" do
    @network.attributes = valid_network_attributes.except(:name)
    @network.should have(1).error_on(:name)
  end
  
  it "should be invalid with a title longer than 128 characters" do
    @network.attributes = valid_network_attributes.with(:name => "a"*129)
    @network.should have(1).error_on(:name)
  end  
  
  it "should be invalid with a description longer than 1024 characters" do
    @network.attributes = valid_network_attributes.with(:description => "a"*1025)
    @network.should have(1).error_on(:description)
  end   
    
  it "should be invalid without an owner" do
    @network.attributes = valid_network_attributes.except(:owner)
  end

  it "should be valid with no description" do
    @network.attributes = valid_network_attributes.except(:description)
  end   
   
  it "should be valid" do
    @network.attributes = valid_network_attributes
    @network.should be_valid
  end  
  
  it "should add the network owner as a member on create" do
    @network = Network.create!(valid_network_attributes)
    @network.organizations.size.should equal(1)
  end
  
end  
