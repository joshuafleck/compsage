require File.dirname(__FILE__) + '/../spec_helper'

module NetworkInvitationSpecHelper

  def valid_network_invitation_attributes
    {
      
    }
  end
end

describe NetworkInvitation, "that does exist" do
  
  it "belongs to a network" do
  #future code here pending review
  end
   
  it "inherits from invitation" do
  #network_invite.class.superclass.name.should == "Invite"
  #future code here pending review
  end    
 
end

describe NetworkInvitation, "that does not exist" do
   
  include NetworkInvitationSpecHelper

  before(:each) do
    @network_invitation = NetworkInvitation.new
  end
  
  it "should be valid on create" do
  #future code here pending review
  end  
    
  it "should be invalid if a network is not specified" do
  #future code here pending review
  end  
  
 end  