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
