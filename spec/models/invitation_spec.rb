require File.dirname(__FILE__) + '/../spec_helper'

module InvitationSpecHelper

  def valid_invitation_attributes
    {
      :inviter => mock_model(Organization)
    }
  end
  
end

describe Invitation do
   
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

describe NetworkInvitation, ".accept!" do
  include NetworkInvitationSpecHelper
  
  before(:each) do
    @invitee = mock_model(Organization)
    @networks = []
    @network = mock_model(Network)
    @invitee.stub!(:networks).and_return(@networks)
    
    @network_invitation = NetworkInvitation.create(
      :invitee => @invitee,
      :network => @network,
      :inviter => mock_model(Organization)
    )
  end
  
  it "should add the network to the invitees networks" do
    @networks.should_receive(:<<).with(@network)
    @network_invitation.accept!
  end
  
  it "should destroy the invitation" do
    @network_invitation.accept!
    @network_invitation.should be_frozen # indicates it was deleted.
  end
  
  after(:each) do
    @network_invitation.destroy
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

  it "should inherit from invitation" do
  	@survey_invitation.class.superclass.name.should == "Invitation"
  end    
 
  it "should belong to a survey" do
  	SurveyInvitation.reflect_on_association(:survey).should_not be_nil
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
      :inviter => organization_mock,
      :name => 'David Peterson',
      :email => 'pete2786@umn.edu'
    }
  end
  
end

describe ExternalInvitation do
   
  include ExternalInvitationSpecHelper
  
  before(:each) do
    @external_invitation = ExternalInvitation.new
  end

  it "should inherit from invitation" do
  	@external_invitation = ExternalInvitation.new
  	@external_invitation.class.superclass.name.should == "Invitation"
  end    
  
  it "should be invalid without an email" do
  	@external_invitation.attributes = valid_external_invitation_attributes.except(:email)
  	@external_invitation.should have(3).errors_on(:email)
  end
 
  it "should be invalid when the email is less than 3 characters in length" do
  	@external_invitation.attributes = valid_external_invitation_attributes.with(:email => "aa")
  	@external_invitation.attributes.should have_at_least(1).errors_on(:email)
  end
 
  it "should be invalid when the email is greater than 100 characters in length" do
  	@external_invitation.attributes = valid_external_invitation_attributes.with(:email => "a"*100 + "@gmail.com")
  	@external_invitation.attributes.should have_at_least(1).errors_on(:email)
  end
 
  it "should be invalid when the email not a valid email address" do
  	@external_invitation.attributes = valid_external_invitation_attributes.with(:email => "This is not an email")
  	@external_invitation.attributes.should have_at_least(1).errors_on(:email)
  end
  
  it "should be invalid when the name is less than 2 characters in length" do
  	@external_invitation.attributes = valid_external_invitation_attributes.with(:name => "a")
  	@external_invitation.valid?
  	@external_invitation.attributes.should have_at_least(1).errors_on(:name)
  end
 
  it "should be invalid when the name is greater than 100 characters in length" do
  	@external_invitation.attributes = valid_external_invitation_attributes.with(:name => "a" * 101)
  	@external_invitation.attributes.should have_at_least(1).errors_on(:name)
  end
  
  it "should be valid" do
  	@external_invitation.attributes = valid_external_invitation_attributes
  	@external_invitation.should be_valid
  end
 
end

describe ExternalInvitation, "that exists" do
   
  include ExternalInvitationSpecHelper

end  
 
module ExternalNetworkInvitationSpecHelper

  def valid_external_network_invitation_attributes
    {
      :name => 'David Peterson',
      :email => 'eazydp@gmail.com',
      :inviter => organization_mock,
      :network => mock_model(Network)
    }
  end
  
end

describe ExternalNetworkInvitation do
   
  include ExternalNetworkInvitationSpecHelper

  before(:each) do
    @external_network_invitation = ExternalNetworkInvitation.new
  end

  it "should belong to a network" do
  	ExternalNetworkInvitation.reflect_on_association(:network).should_not be_nil
  end
   
  it "should inherit from external_invitation" do
  	 @external_network_invitation.class.superclass.name.should == "ExternalInvitation"
  end    
     
  it "should be invalid if a network is not specified" do
  	 @external_network_invitation.attributes = valid_external_network_invitation_attributes.except(:network)
  	 @external_network_invitation.should have(1).errors_on(:network)
  end  
   
  it "should be valid" do
     @external_network_invitation.attributes = valid_external_network_invitation_attributes
     @external_network_invitation.should be_valid
  end  
 
end

describe ExternalNetworkInvitation, "that exists" do
   
  include ExternalNetworkInvitationSpecHelper

  before(:each) do
    @external_network_invitation = ExternalNetworkInvitation.new
    @external_network_invitation.attributes = valid_external_network_invitation_attributes
    @external_network_invitation.save
  end
  
  after(:each) do
    @external_network_invitation.destroy
  end
  
  it "should have a key" do
  	@external_network_invitation.key.should_not be_nil
  end

 end 
 
module ExternalSurveyInvitationSpecHelper

  def valid_external_survey_invitation_attributes
    {
      :name => 'David E. Peteron',
      :email => 'pete2786@umn.edu',
      :inviter => organization_mock,
      :survey => mock_model(Survey),
      :discussion => [],
      :responses => []
    }
  end
  
end

describe ExternalSurveyInvitation do
   
  include ExternalSurveyInvitationSpecHelper

  before(:each) do
    @external_survey_invitation = ExternalSurveyInvitation.new
  end

  it "should inherit from external_invitation" do
  	@external_survey_invitation.class.superclass.name.should == "ExternalInvitation"
  end    
 
  it "should belong to a survey" do
  	ExternalSurveyInvitation.reflect_on_association(:survey).should_not be_nil 
  end
  
  it "should have many discussions" do
  	ExternalSurveyInvitation.reflect_on_association(:discussions).should_not be_nil 
  end
  
  it "should have many responses" do
  	ExternalSurveyInvitation.reflect_on_association(:responses).should_not be_nil 
  end
  
  it "should be invalid if a survey is not specified" do
  	@external_survey_invitation.attributes = valid_external_survey_invitation_attributes.except(:survey)
  	@external_survey_invitation.should have(1).errors_on(:survey)
  end
      
  it "should be invalid if a name is not specified" do
  	@external_survey_invitation.attributes = valid_external_survey_invitation_attributes.except(:name)
  	@external_survey_invitation.should have(1).errors_on(:name)
  end
     
  it "should be valid" do
  	@external_survey_invitation.attributes = valid_external_survey_invitation_attributes
  	@external_survey_invitation.should be_valid
  end  
 
end

describe ExternalSurveyInvitation, "that exists" do
   
  include ExternalSurveyInvitationSpecHelper

  before(:each) do
    @external_survey_invitation = ExternalSurveyInvitation.new
    @external_survey_invitation.attributes = valid_external_survey_invitation_attributes
    @external_survey_invitation.save
  end
  
  after(:each) do
    @external_survey_invitation.destroy
  end
  
  it "should have a key" do
  	@external_survey_invitation.key.should_not be_nil
  end

end 
