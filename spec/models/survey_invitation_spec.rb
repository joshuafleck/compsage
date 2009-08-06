require File.dirname(__FILE__) + '/../spec_helper'

describe SurveyInvitation do

  before(:each) do
    @survey = Factory.create(:survey, :end_date => Time.now)
    @invitation = Factory.build(:survey_invitation, :survey => @survey)
  end
  
  after(:each) do
    @survey.destroy
  end  
   
  it "should belong to a survey" do
    SurveyInvitation.reflect_on_association(:survey).should_not be_nil
  end
   
  it "should be invalid without a survey" do
    @invitation.survey = nil
    @invitation.should have(1).error_on(:survey)
  end
   
  it "should be invalid without an invitee" do
    @invitation.invitee = nil
    @invitation.should have(1).error_on(:invitee)
  end

  it "should be invalid if the invitee is already invited" do
    @invitation.save!
    @invitation.reload
    @duplicate_invitation = @invitation.survey.invitations.new(
      :inviter => @invitation.inviter, 
      :invitee => @invitation.invitee)
      
    @duplicate_invitation.should have(1).error_on(:base)
    @invitation.destroy
  end  
  
  it "should be invalid if the invitee is the survey sponsor" do        
    @invitation.invitee = @survey.sponsor    
    @invitation.should have(1).error_on(:base)
  end  
  
  it "should have a sent status after sending the invitation" do
    @invitation.save!
    lambda{ @invitation.send_invitation! }.should change(@invitation, :aasm_state).from("pending").to("sent")
    @invitation.destroy
  end    
  
  it "should have a declined status after declining the invitation" do
    @invitation.save!
    @invitation.send_invitation!
    lambda{ @invitation.decline! }.should change(@invitation, :aasm_state).from("sent").to("declined")
    @invitation.destroy
  end  
  
  it "should have a fulfilled status after fulfilling the invitation" do
    @invitation.save!
    @invitation.send_invitation!
    lambda{ @invitation.fulfill! }.should change(@invitation, :aasm_state).from("sent").to("fulfilled")
    @invitation.destroy
  end     
  
end 
