require File.dirname(__FILE__) + '/../spec_helper'

def valid_participation_attributes
  {
    :survey => mock_model(Survey, :id => 1, :sponsor => mock_model(Organization)),
    :participant => mock_model(Organization, :id => 1)
  }
end

describe Participation do
  before(:each) do
    @participation = Participation.new
  end  
  
  it "should be valid" do
    @participation.attributes = valid_participation_attributes
    @participation.should be_valid
  end
  
  it "should belong to a survey" do
  	Participation.reflect_on_association(:survey).should_not be_nil
  end
  
  it "should belong to a participant" do
  	Participation.reflect_on_association(:participant).should_not be_nil
  end
  
  it "should have many responses" do
    Participation.reflect_on_association(:participant).should_not be_nil
  end
  
  it "should be invalid without a survey" do
    @participation.attributes = valid_participation_attributes.except(:survey)
    @participation.should_not be_valid
  end
  
  it "should be invalid without a participant" do
    @participation.attributes = valid_participation_attributes.except(:participant)
    @participation.should_not be_valid
  end
  
  it "should create a survey subscription when created by an organization" do
    @participation = Factory.create(:participation) 
    sub = SurveySubscription.find_by_survey_id_and_organization_id(@participation.survey.id, @participation.participant.id)
    sub.should_not be_nil
    sub.relationship.should == "participant"
    @participation.destroy
  end
  
  it "should fufill the invitation when an invited organization has responded" do
    @participation = Factory.build(:participation) 
    invitation = SurveyInvitation.new(:inviter => @participation.survey.sponsor, :invitee => @participation.participant, :survey => @participation.survey)
    invitation.save!
    @participation.save!
    invitation = SurveyInvitation.find_by_id(invitation.id)
    invitation.aasm_state.should == "fufilled"
    @participation.destroy
    invitation.destroy
  end
  
end
