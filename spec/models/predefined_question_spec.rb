require File.dirname(__FILE__) + '/../spec_helper'

describe PredefinedQuestion do
  
  before do
    @predefined_question = Factory.build(:predefined_question, :name => "PQ 1") 
  end
  
  it "should build questions" do
    @predefined_question.save!
    survey = Factory.build(:survey)
    survey.questions.destroy_all
    @predefined_question.build_questions(survey)
    survey.save
    survey.questions[0].text.should eql("PQ 1 text")
  end
  
end
