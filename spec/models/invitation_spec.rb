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

describe Invitation, "self.create_internal_or_external_invitations" do
   
  before(:each) do
    @inviter = Factory.create(:organization)
    @network = Factory.create(:network)
    @survey = Factory.create(:survey)
    @networks = [Factory.create(:network)]
    @invitees = [Factory.create(:organization)]
    @external_invitees = [{:email => "flec0025@umn.edu",:organization_name => "test1"}]
  end
  
  it "should collect any invitations that were not valid" do
    @external_invitees[0][:organization_name] = nil
    
    invitations, invalid_invitations = Invitation.create_internal_or_external_invitations(
      @external_invitees,
      [],
      [],
      @inviter,
      @survey)
    
    invitations.size.should eql(0)  
    invalid_invitations.size.should eql(1)
  end
  
  it "should return the valid external invitations" do    
    invitations, invalid_invitations = Invitation.create_internal_or_external_invitations(
      @external_invitees,
      [],
      [],
      @inviter,
      @survey)
    
    invitations.size.should eql(1)  
    invalid_invitations.size.should eql(0)
  end
   
  it "should invite all members of an invited network except the inviter" do
    org = Factory.create(:organization)
    Factory.create(:network_membership, :network => @networks[0], :organization => org)
    Factory.create(:network_membership, :network => @networks[0], :organization => @inviter)
    invitations, invalid_invitations = Invitation.create_internal_or_external_invitations(
      [],
      [],
      @networks,
      @inviter,
      @survey)
    
    invitations.size.should eql(1)  
    invalid_invitations.size.should eql(0)
  end
  
  it "should return the valid internal invitations" do
    invitations, invalid_invitations = Invitation.create_internal_or_external_invitations(
      [],
      @invitees,
      [],
      @inviter,
      @survey)
    
    invitations.size.should eql(1)  
    invalid_invitations.size.should eql(0)
  end
  
  it "should not send an external invitation to a pre-existing member" do 
    org = Factory.create(:organization)
    @external_invitees[0][:email] = org.email
    invitations, invalid_invitations = Invitation.create_internal_or_external_invitations(
      @external_invitees,
      [],
      [],
      @inviter,
      @survey)
    
    invitations.size.should eql(1)  
    invalid_invitations.size.should eql(0)
    invitations[0].class.should eql(SurveyInvitation)    
  end
  
  it "should not send more than one internal invitation to the same invitee" do
    invitations, invalid_invitations = Invitation.create_internal_or_external_invitations(
      [],
      @invitees += @invitees,
      [],
      @inviter,
      @survey)
    
    invitations.size.should eql(1)  
    invalid_invitations.size.should eql(0)
  end
  
end

describe NetworkInvitation do
   
  before(:each) do
    @network = Factory.create(:network)
    @network_invitation = Factory.build(:network_invitation, :network => @network)
  end

  it "should belong to a network" do
    NetworkInvitation.reflect_on_association(:network).should_not be_nil
  end
   
  it "should inherit from invitation" do
    @network_invitation.class.superclass.name.should == "Invitation"
  end    
     
  it "should be invalid if a network is not specified" do
    @network_invitation.network = nil
    @network_invitation.should have(1).error_on(:network)
  end  
   
  it "should be invalid without an invitee" do
    @network_invitation.invitee = nil
    @network_invitation.should have(1).error_on(:invitee)
  end
  
  it "should be invalid without an inviter" do
    @network_invitation.inviter = nil
    @network_invitation.should have(1).error_on(:inviter)
  end
  
  it "should be invalid if the invitee is already invited" do
    @network_invitation.save
    @new_invitation = Factory.build(:network_invitation,
                                     :network => @network,
                                     :invitee => @network_invitation.invitee)

    @new_invitation.should_not be_valid
    @new_invitation.should have(1).error_on(:base)
  end  
  
  it "should be invalid if the invitee is already a member" do
    Factory.create(
      :network_membership,
      :network => @network_invitation.network, 
      :organization => @network_invitation.invitee)
      
    @network_invitation.should have(1).error_on(:base)
  end 
  
  it "should be invalid if the invitee is the network owner" do
    @network_invitation.network.owner = @network_invitation.invitee
    @network_invitation.network.save!
    
    @network_invitation.should have(1).error_on(:base)
  end   
  
  it "should be valid" do
    @network_invitation.should be_valid
  end  
 
end

describe NetworkInvitation, ".accept!" do
  
  before(:each) do
    @invitee = Factory.create(:organization)
    @network = Factory.create(:network)   
    @network_invitation = Factory.create(:network_invitation,:network => @network, :invitee => @invitee)
    @networks = []
    @invitee.stub!(:networks).and_return(@networks) 
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

describe SurveyInvitation do
   
  before(:each) do
    @survey = Factory.build(:survey)
    @survey_invitation = Factory.build(:survey_invitation, :survey => @survey)
  end

  it "should inherit from invitation" do
    @survey_invitation.class.superclass.name.should == "Invitation"
  end    
 
  it "should belong to a survey" do
    SurveyInvitation.reflect_on_association(:survey).should_not be_nil
  end
  
  it "should be invalid if a survey is not specified" do
    @survey_invitation.survey = nil
    @survey_invitation.should have(1).errors_on(:survey)
  end
    
  it "should be invalid without an invitee" do
    @survey_invitation.invitee = nil
    @survey_invitation.should have(1).errors_on(:invitee)
  end
  
  it "should be invalid if the invitee is already invited" do
    @survey_invitation.save
    @new_invitation = Factory.build(:survey_invitation,
                                    :survey => @survey,
                                    :invitee => @survey_invitation.invitee)

    @new_invitation.should have(1).error_on(:base)
  end  
  
  it "should be invalid if the invitee is the survey sponsor" do
    @survey_invitation.survey.sponsor = @survey_invitation.invitee
    @survey_invitation.survey.save!
    
    @survey_invitation.should have(1).error_on(:base)
  end   
     
  it "should be valid" do   
    @survey_invitation.should be_valid
  end  
 
  it "should send a notification email when asked" do
    Notifier.should_receive(:deliver_survey_invitation_notification)
    @survey_invitation.aasm_state = :pending
    @survey_invitation.send_invitation
  end

  it "should save as pending when the survey is pending" do
    @survey_invitation.survey.stub!(:running?).and_return(false)
    @survey_invitation.save
    @survey_invitation.should be_pending
  end
  
  it "should save as running when the survey is running" do
    @survey_invitation.survey.stub!(:running?).and_return(true)
    @survey_invitation.save
    @survey_invitation.should be_sent
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

describe ExternalNetworkInvitation do
   
  before(:each) do
    @network = Factory.create(:network)
    @external_network_invitation = Factory.build(:external_network_invitation,
                                                 :network => @network)
  end

  it "should belong to a network" do
    ExternalNetworkInvitation.reflect_on_association(:network).should_not be_nil
  end
   
  it "should inherit from external_invitation" do
    @external_network_invitation.class.superclass.name.should == "ExternalInvitation"
  end    
     
  it "should be invalid if a network is not specified" do
    @external_network_invitation.network = nil
    @external_network_invitation.should have(1).errors_on(:network)
  end  
  
  it "should be invalid if the invitee is already invited" do
    @external_network_invitation.save
    @new_invitation = Factory.build(:external_network_invitation,
                                    :network => @network,
                                    :email => @external_network_invitation.email)
    @new_invitation.should have(1).errors_on(:base)
  end  
   
  it "should be valid" do
     @external_network_invitation.should be_valid
  end  
 
  it "should have a key" do
    @external_network_invitation.save!
    @external_network_invitation.key.should_not be_nil
  end

end 

describe ExternalSurveyInvitation do

  before(:each) do
    @external_survey_invitation = Factory.build(:external_survey_invitation)
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
  
  it "should have many participations" do
    ExternalSurveyInvitation.reflect_on_association(:participations).should_not be_nil 
  end
  
  it "should be invalid if a survey is not specified" do
    @external_survey_invitation.survey = nil
    @external_survey_invitation.should have(1).errors_on(:survey)
  end
      
  it "should be invalid if an organization name is not specified" do
    @external_survey_invitation.organization_name = nil
    @external_survey_invitation.should have(1).errors_on(:organization_name)
  end
  
  it "should be invalid if the invitee is already invited" do
    @external_survey_invitation.save
    @new_invitation = Factory.create(:external_survey_invitation,
                                     :survey => @external_survey_invitation.survey,
                                     :email => @external_survey_invitation.email)

    @new_invitation.should have(1).errors_on(:base)
  end  
        
  it "should be valid" do
    @external_survey_invitation.should be_valid
  end  
 
  it "should have a key" do
    @external_survey_invitation.save!
    @external_survey_invitation.key.should_not be_nil
  end

  it "should send a notification email when asked" do
    Notifier.should_receive(:deliver_external_survey_invitation_notification)
    @external_survey_invitation.aasm_state = :pending
    @external_survey_invitation.send_invitation
  end

  it "should save as pending when the survey is pending" do
    @external_survey_invitation.survey.stub!(:running?).and_return(false)
    @external_survey_invitation.save
    @external_survey_invitation.should be_pending
  end
  
  it "should save as running when the survey is running" do
    @external_survey_invitation.survey.stub!(:running?).and_return(true)
    @external_survey_invitation.save
    @external_survey_invitation.should be_sent
  end
end 
