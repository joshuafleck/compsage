require File.dirname(__FILE__) + '/../spec_helper'

describe PredefinedQuestion do
  
  before do
    @predefined_question = Factory.build(:predefined_question, :name => "PQ 1", :question_hash => [{:response_type => "NumericalResponse", :text =>  "question text", :parent_question_index => 0}]) 
  end
  
  it "should build questions" do
    @predefined_question.save!
    @survey = Factory.create(:survey)
    @questions = @predefined_question.build_questions(@survey)
    @questions.size.should eql(1)
    # make sure follow-up questions can be specified
    @questions[0].parent_question.should eql(@questions[0])
  end
  
end
