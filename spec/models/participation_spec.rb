require File.dirname(__FILE__) + '/../spec_helper'

def valid_participation_attributes
  {
    :survey => Factory.create(:survey),
    :participant => mock_model(Organization, :id => 1),
    :responses => [mock_model(Response, :question => mock_model(Question, :parent_question => nil), :question_id => 1, :valid? => true)]
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
  
  it "should fulfill the invitation when an invited organization has responded" do
    @survey = Factory.create(:survey)
    @participant = Factory.create(:organization)
    invitation = Factory.create(:survey_invitation,
      :inviter => @survey.sponsor, 
      :invitee => @participant, 
      :survey => @survey,
      :aasm_state => 'sent')
    @participation = Factory.create(:participation, :survey => @survey, :participant => @participant)
    invitation.reload
    invitation.aasm_state.should == "fulfilled"
    @participation.destroy
    invitation.destroy
  end
end


module ParticipationCreationHelper
  def participation_responding_to(*questions)
    participation = Factory.build(:participation, :survey => @survey, :participant => @participant, :responses => [])
    questions.each do |question|
      if question.is_a?(Hash) then
        # Has question and value.
        participation.responses << Factory.build(:numerical_response, :question => question.keys.first, :response => question.values.first)
      else
        participation.responses << Factory.build(:numerical_response, :question => question, :response => 1)
      end
    end

    return participation
  end
end

describe Participation, "in a survey with required questions" do
  include ParticipationCreationHelper
  
  before do
    @survey = Factory.create(:survey)
    @participant = Factory.create(:organization)
    @required_question = Factory.create(:question, :survey => @survey, :required => 1)
    @optional_question = Factory.create(:question, :survey => @survey, :required => 0)
    @yes_no_question =   Factory.create(:question,
                                        :survey => @survey,
                                        :required => 0,
                                        :response_type => 'MultipleChoiceResponse',
                                        :options => ['Yes', 'No'])

    @required_follow_up_to_optional_question = Factory.create(:question,
                                                              :survey => @survey,
                                                              :required => 1,
                                                              :parent_question_id => @optional_question.id)
    @required_follow_up_to_required_question = Factory.create(:question,
                                                              :survey => @survey,
                                                              :required => 1,
                                                              :parent_question_id => @required_question.id)
    @optional_follow_up_to_optional_question = Factory.create(:question,
                                                              :survey => @survey,
                                                              :required => 0,
                                                              :parent_question_id => @optional_question.id)
    @optional_follow_up_to_required_question = Factory.create(:question,
                                                              :survey => @survey,
                                                              :required => 0,
                                                              :parent_question_id => @required_question.id)
    @required_follow_up_to_yes_no_question   = Factory.create(:question,
                                                              :survey => @survey,
                                                              :required => 1,
                                                              :parent_question_id => @yes_no_question.id)

  end

  it "should be valid when only the required questions have been answered" do
    @participation = participation_responding_to(@required_question, @required_follow_up_to_required_question,
                                                 @optional_question, @required_follow_up_to_optional_question)
    @participation.should be_valid
  end

  it "should be valid when not responding to a required question that is a follow-up to an optional question that hasn't been answered" do
    @participation = participation_responding_to(@required_question, @required_follow_up_to_required_question)
    @participation.should be_valid
  end

  it "should not be valid if required questions do not have responses" do
    @participation = participation_responding_to(@optional_question) # nothing
    @participation.should_not be_valid
  end
  
  it "should not be valid if a required follow-up has not been answered" do
    @participation = participation_responding_to(@required_question, @optional_question,
                                                 @required_follow_up_to_optional_question)
    @participation.should_not be_valid
  end

  it "should not be valid if a follow-up question has been answered and the parent question has not" do
    @participation = participation_responding_to(@required_question, @required_follow_up_to_required_question,
                                                 @required_follow_up_to_optional_question)
    @participation.should_not be_valid
  end

  it "should be valid if not answering a required follow-up to a yes/no with a no answer" do
    @participation = participation_responding_to(@required_question, @required_follow_up_to_required_question,
                                                 {@yes_no_question => 1})
    @participation.should be_valid
  end

  it "should not be valid if not answering a required follow-up to a yes/no with a yes answer" do
    @participation = participation_responding_to(@required_question, @required_follow_up_to_required_question,
                                                 {@yes_no_question => 0})
    @participation.should_not be_valid
  end
end

describe Participation, "in a survey with no required questions" do
  include ParticipationCreationHelper

  before do
    @survey = Factory.create(:survey)
    @participant = Factory.create(:organization)
    @optional_question = Factory.create(:question, :survey => @survey, :required => 0)
    @optional_follow_up_to_optional_question = Factory.create(:question,
                                                              :survey => @survey,
                                                              :required => 0,
                                                              :parent_question_id => @optional_question.id)
  end

  it "should be valid with a single response" do
    @participation = participation_responding_to(@optional_question)
    @participation.should be_valid
  end

  it "should not be valid with no response" do
    @participation = participation_responding_to()  # nothing
    @participation.should_not be_valid
  end
end


