require File.dirname(__FILE__) + '/../spec_helper'

describe ExternalSurveyInvitation do

  before(:each) do
    @survey = Factory.build(:survey, :end_date => Time.now)
    @invitation = Factory.build(:external_survey_invitation, :survey => @survey)
  end
   
  it "should be valid" do
    @invitation.should be_valid
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
      
  it "should be invalid without a survey" do
    @invitation.survey = nil
    @invitation.should have(1).error_on(:survey)
  end

  it "should be invalid if the invitee is already invited" do
    @invitation.save!
    @duplicate_invitation = @invitation.survey.external_invitations.new(
      :inviter => @invitation.inviter, 
      :email => @invitation.email, 
      :organization_name => @invitation.organization_name)
      
    @duplicate_invitation.should have(1).error_on(:base)
    @invitation.destroy
  end  
      
  it "should have a sent status after sending the invitation" do
    @invitation.save!
    lambda{ @invitation.send_invitation! }.should change(@invitation, :aasm_state).from("pending").to("sent")
    @invitation.destroy
  end
  
  it "should send a notification email when asked" do
    @invitation.save!
    Notifier.should_receive(:deliver_external_survey_invitation_notification)
    @invitation.send_invitation!
    @invitation.destroy
  end   
      
end  

describe "accepting an invitation" do

  before(:each) do
    @invitee = Factory(:organization)
    @invitation = Factory(:sent_external_survey_invitation)
    @participation = Factory(:participation, :participant => @invitation, :survey => @invitation.survey)
    @discussion = Factory(:discussion, :responder => @invitation, :survey => @invitation.survey)
  end
  
  after(:each) do
    @invitation.destroy
    @participation.destroy
    @discussion.destroy
    @invitee.destroy
  end 
  
  it "should move the partiticipation from the invitation to the organization" do
    lambda{ @invitation.accept!(@invitee) }.should change(@invitee.participations, :count).by(1)
  end
    
  it "should subscribe the organization to the survey" do
    lambda{ @invitation.accept!(@invitee) }.should change(@invitee.survey_subscriptions, :count).by(1)
  end
    
  it "should move the discussions from the invitation to the organization" do
    lambda{ @invitation.accept!(@invitee) }.should change(@invitee.discussions, :count).by(1)
  end
    
  it "should change the invitation to an internal invitation" do
    lambda{ @invitation.accept!(@invitee) }.should change(@invitation, :type).from("ExternalSurveyInvitation").to("SurveyInvitation")
  end
      
  it "should invite the organization to the survey" do
    lambda{ @invitation.accept!(@invitee) }.should change(@invitee.invited_surveys, :count).by(1)
  end
        
end
