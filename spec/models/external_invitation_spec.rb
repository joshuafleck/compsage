require File.dirname(__FILE__) + '/../spec_helper'

module ExternalInvitationSpecHelper

  def valid_external_invitation_attributes
    {
      
    }
  end
  
end

describe ExternalInvitation, :shared => true do
   
  include ExternalInvitationSpecHelper

  before(:each) do
    @invitation = ExternalInvitation.new
    @invitation.attributes = valid_external_invitation_attributes
  end
  
  it "should belong to an inviter" do
  	pending
  end
  
  it "should be invalid without an inviter" do
  	pending
  end
 
  it "should be invalid without an email" do
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
 
end

describe ExternalInvitation, "that does exist", :shared => true do
   
  include ExternalInvitationSpecHelper

  before(:each) do
    @invitation = ExternalInvitation.new
    @invitation.attributes = valid_external_invitation_attributes
    @invitation.save
  end
  
  after(:each) do
    @invitation.destroy
  end  
       
  it "should not be accepted" do
  	pending
  end  
       
  it "should have a key" do
  	pending
  end  

end  
 
module ExternalNetworkInvitationSpecHelper

  def valid_external_network_invitation_attributes
    {
      
    }
  end
  
end

describe ExternalNetworkInvitation do
   
  include ExternalNetworkInvitationSpecHelper

  before(:each) do
    @network_invitation = ExternalNetworkInvitation.new
    @network_invitation.attributes = valid_external_network_invitation_attributes
  end

  it_should_behave_like "ExternalInvitation"  

  it "should belong to a network" do
  	pending
  end
   
  it "should inherit from external_invitation" do
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

describe ExternalNetworkInvitation, "that does exist" do
   
  include ExternalNetworkInvitationSpecHelper

  before(:each) do
    @network_invitation = ExternalNetworkInvitation.new
    @network_invitation.attributes = valid_external_network_invitation_attributes
    @network_invitation.save
  end
  
  after(:each) do
    @network_invitation.destroy
  end  

  it_should_behave_like "ExternalInvitation that does exist" 

 end 
 
module ExternalSurveyInvitationSpecHelper

  def valid_external_survey_invitation_attributes
    {
      
    }
  end
  
end

describe ExternalSurveyInvitation do
   
  include ExternalSurveyInvitationSpecHelper

  before(:each) do
    @survey_invitation = ExternalSurveyInvitation.new
    @survey_invitation.attributes = valid_external_survey_invitation_attributes
  end

  it_should_behave_like "ExternalInvitation"  

  it "should inherit from external_invitation" do
  	#survey_invite.class.superclass.name.should == "Invite"
  	pending
  end    
 
  it "should belong to a survey" do
  	pending 
  end
  
  it "should have many discussions" do
  	pending 
  end
  
  it "should have many responses" do
  	pending 
  end
  
  it "should be invalid if a survey is not specified" do
  	pending
  end
      
  it "should be invalid if a name is not specified" do
  	pending
  end
     
  it "should be valid" do
  	pending
  end  
 
end

describe ExternalSurveyInvitation, "that does exist" do
   
  include ExternalSurveyInvitationSpecHelper

  before(:each) do
    @survey_invitation = ExternalSurveyInvitation.new
    @survey_invitation.attributes = valid_external_survey_invitation_attributes
    @survey_invitation.save
  end
  
  after(:each) do
    @survey_invitation.destroy
  end  

  it_should_behave_like "ExternalInvitation that does exist" 

end 
