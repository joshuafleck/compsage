require File.dirname(__FILE__) + '/../spec_helper'

module InvitationSpecHelper

  def valid_invitation_attributes
    {
      
    }
  end
end

describe Invitation, "that does not exist", :shared => true do

  it "should belong to an invitee" do
  #future code here pending review
  end
  
  it "should belong to an inviter" do
  #future code here pending review
  end
  
end

describe Invitation, "that does exist", :shared => true do
   
  include InvitationSpecHelper

  it "is invalid without an invitee" do
  #future code here pending review
  end
  
  it "is invalid without an inviter" do
  #future code here pending review
  end
  
end

module NetworkInvitationSpecHelper

  def valid_network_invitation_attributes
    {
      
    }
  end
end

describe NetworkInvitation, "that does not exist" do

  it_should_behave_like "Invitation that does not exist"  

  it "belongs to a network" do
  #future code here pending review
  end
   
  it "inherits from invitation" do
  #network_invite.class.superclass.name.should == "Invite"
  #future code here pending review
  end    
 
end

describe NetworkInvitation, "that does exist" do
   
  include NetworkInvitationSpecHelper

  before(:each) do
    @network_invitation = NetworkInvitation.new
  end

  it_should_behave_like "Invitation that does exist" 
  
  it "should be valid on create" do
  #future code here pending review
  end  
    
  it "should be invalid if a network is not specified" do
  #future code here pending review
  end  
  
 end 
 
module SurveyInvitationSpecHelper

  def valid_survey_invitation_attributes
    {
      
    }
  end
end

describe SurveyInvitation, "that does not exist" do

  it_should_behave_like "Invitation that does not exist"  

  it "inherits from invitation" do
  #survey_invite.class.superclass.name.should == "Invite"
  #future code here pending review
  end    
 
  it "should belong to a survey" do
  #future code here pending review  
  end
  
end

describe SurveyInvitation, "that does exist" do
   
  include SurveyInvitationSpecHelper

  before(:each) do
    @survey_invitation = SurveyInvitation.new
  end

  it_should_behave_like "Invitation that does exist" 
      
  it "should be valid on create" do
  #future code here pending review
  end  
 
  it "should be invalid if a survey is not specified" do
    #future code here pending review
  end
  
end 
