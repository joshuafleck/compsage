require File.dirname(__FILE__) + '/../spec_helper'

module NetworkInvitationSpecHelper

  def valid_network_invitation_attributes
    {
      
    }
  end
end

describe NetworkInvitation, "class relationships" do
  
  it "belongs to a network" do
  #future code here pending review
  end
   
  it "inherits from invitation" do
  #network_invite.class.superclass.name.should == "Invite"
  #future code here pending review
  end    
 
end

describe NetworkInvitation, "creating/updating" do
   
  include NetworkInvitationSpecHelper

  before(:each) do
    @network_invitation = NetworkInvitation.new
  end
  
  it "requires that a network is specified" do
  #future code here pending review
  end  
  
 end  