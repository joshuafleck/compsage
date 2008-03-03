require File.dirname(__FILE__) + '/../spec_helper'

module InvitationSpecHelper

  def valid_invitation_attributes
    {
      
    }
  end
  
end

describe Invitation, :shared => true do
   
  include InvitationSpecHelper

  before(:each) do
    @invitation = Invitation.new
    @invitation.attributes = valid_invitation_attributes
  end
  
  it "should belong to an invitee" do
  	pending
  end
  
  it "should belong to an inviter" do
  	pending
  end
  
  it "should be invalid without an invitee" do
  	pending
  end
  
  it "should be invalid without an inviter" do
  	pending
  end
 
end

describe Invitation, "that does exist", :shared => true do
   
  include InvitationSpecHelper

  before(:each) do
    @invitation = Invitation.new
    @invitation.attributes = valid_invitation_attributes
    @invitation.save
  end
  
  after(:each) do
    @invitation.destroy
  end  
       
  it "should not be accepted" do
  	pending
  end  
  
end  
 
module NetworkInvitationSpecHelper

  def valid_network_invitation_attributes
    {
      
    }
  end
  
end

describe NetworkInvitation do
   
  include NetworkInvitationSpecHelper

  before(:each) do
    @network_invitation = NetworkInvitation.new
    @network_invitation.attributes = valid_network_invitation_attributes
  end

  it_should_behave_like "Invitation"  

  it "should belong to a network" do
  	pending
  end
   
  it "should inherit from invitation" do
  	#network_invite.class.superclass.name.should == "Invite"
  	pending
  end    
     
  it "should be invalid if a network is not specified" do
  	pending
  end  
   
  it "should be valid" do
  	pending
  end  
 
end

describe NetworkInvitation, "that does exist" do
   
  include NetworkInvitationSpecHelper

  before(:each) do
    @network_invitation = NetworkInvitation.new
    @network_invitation.attributes = valid_network_invitation_attributes
    @network_invitation.save
  end
  
  after(:each) do
    @network_invitation.destroy
  end  

  it_should_behave_like "Invitation that does exist" 

 end 
 
module SurveyInvitationSpecHelper

  def valid_survey_invitation_attributes
    {
      
    }
  end
  
end

describe SurveyInvitation do
   
  include SurveyInvitationSpecHelper

  before(:each) do
    @survey_invitation = SurveyInvitation.new
    @survey_invitation.attributes = valid_survey_invitation_attributes
  end

  it_should_behave_like "Invitation"  

  it "should inherit from invitation" do
  	#survey_invite.class.superclass.name.should == "Invite"
  	pending
  end    
 
  it "should belong to a survey" do
  	pending 
  end
  
  it "should be invalid if a survey is not specified" do
  	pending
  end
       
  it "should be valid" do
  	pending
  end  
 
end

describe SurveyInvitation, "that does exist" do
   
  include SurveyInvitationSpecHelper

  before(:each) do
    @survey_invitation = SurveyInvitation.new
    @survey_invitation.attributes = valid_survey_invitation_attributes
    @survey_invitation.save
  end
  
  after(:each) do
    @survey_invitation.destroy
  end  

  it_should_behave_like "Invitation that does exist" 

end 
