require File.dirname(__FILE__) + '/../spec_helper'

module InvitationSpecHelper

  def valid_invitation_attributes
    {
      :inviter => mock_model(Organization)
    }
  end
  
end

describe Invitation, :shared => true do
   
  include InvitationSpecHelper

  before(:each) do
    @invitation = Invitation.new
  end
  
  it "should belong to an invitee" do
  	Invitation.reflect_on_association(:invitee).should_not be_nil
  end
  
  it "should belong to an inviter" do
  	Invitation.reflect_on_association(:inviter).should_not be_nil
  end
  
  it "should be invalid without an inviter" do
  	@invitation.attributes = valid_invitation_attributes.except(:inviter)
  	@invitation.should have(1).errors_on(:inviter)
  end
 
end

module NetworkInvitationSpecHelper

  def valid_network_invitation_attributes
    {
      :inviter => mock_model(Organization),
      :invitee => mock_model(Organization),
      :network => mock_model(Network)
    }
  end
  
end

describe NetworkInvitation do
   
  include NetworkInvitationSpecHelper

  before(:each) do
    @network_invitation = NetworkInvitation.new
  end

  it_should_behave_like "Invitation"

  it "should belong to a network" do
  	NetworkInvitation.reflect_on_association(:network).should_not be_nil
  end
   
  it "should inherit from invitation" do
  	@network_invitation.class.superclass.name.should == "Invitation"
  end    
     
  it "should be invalid if a network is not specified" do
  	@network_invitation.attributes = valid_network_invitation_attributes.except(:network)
  	@network_invitation.should have(1).error_on(:network)
  end  
   
  it "should be invalid without an invitee" do
  	@network_invitation.attributes = valid_network_invitation_attributes.except(:invitee)
    @network_invitation.should have(1).error_on(:invitee)
  end
  
  it "should be invalid without an inviter" do
    @network_invitation.attributes = valid_network_invitation_attributes.except(:inviter)
    @network_invitation.should have(1).error_on(:inviter)
  end
  
  it "should be valid" do
  	@network_invitation.attributes = valid_network_invitation_attributes
    @network_invitation.should be_valid
  end  
 
end

module SurveyInvitationSpecHelper

  def valid_survey_invitation_attributes
    {
      :inviter => organization_mock,
      :invitee => organization_mock,  
      :survey => survey_mock
    }
  end
  
end

describe SurveyInvitation do
   
  include SurveyInvitationSpecHelper

  before(:each) do
    @survey_invitation = SurveyInvitation.new
  end

  it_should_behave_like "Invitation"  

  it "should inherit from invitation" do
  	@survey_invitation.class.superclass.name.should == "Invitation"
  end    
 
  it "should belong to a survey" do
  	Discussion.reflect_on_association(:survey).should_not be_nil
  end
  
  it "should be invalid if a survey is not specified" do
    @survey_invitation.attributes = valid_survey_invitation_attributes.except(:survey)
    @survey_invitation.should have(1).errors_on(:survey)
  end
    
  it "should be invalid without an invitee" do
    @survey_invitation.attributes = valid_survey_invitation_attributes.except(:invitee)
    @survey_invitation.should have(1).errors_on(:invitee)
  end
     
  it "should be valid" do  	
    @survey_invitation.attributes = valid_survey_invitation_attributes
    @survey_invitation.should be_valid
  end  
 
end


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
 
  it_should_behave_like "Invitation"  

  it "should inherit from invitation" do
  	#network_invite.class.superclass.name.should == "Invite"
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

describe ExternalInvitation, "that exists", :shared => true do
   
  include ExternalInvitationSpecHelper

  before(:each) do
    @invitation = ExternalInvitation.new
    @invitation.attributes = valid_external_invitation_attributes
    @invitation.save
  end
  
  after(:each) do
    @invitation.destroy
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

describe ExternalNetworkInvitation, "that exists" do
   
  include ExternalNetworkInvitationSpecHelper

  before(:each) do
    @network_invitation = ExternalNetworkInvitation.new
    @network_invitation.attributes = valid_external_network_invitation_attributes
    @network_invitation.save
  end
  
  after(:each) do
    @network_invitation.destroy
  end  

  it_should_behave_like "ExternalInvitation that exists" 

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

describe ExternalSurveyInvitation, "that exists" do
   
  include ExternalSurveyInvitationSpecHelper

  before(:each) do
    @survey_invitation = ExternalSurveyInvitation.new
    @survey_invitation.attributes = valid_external_survey_invitation_attributes
    @survey_invitation.save
  end
  
  after(:each) do
    @survey_invitation.destroy
  end  

  it_should_behave_like "ExternalInvitation that exists" 

end 
