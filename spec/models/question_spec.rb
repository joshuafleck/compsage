require File.dirname(__FILE__) + '/../spec_helper'

module QuestionSpecHelper

  def valid_question_attributes
    {
      :text => "What is the meaning of life?",
      :position => 1,
      :question_type => 'Yes/No',
      :response_type => 'MultipleChoiceResponse',
      :question_parameters => {},
      :html_parameters => {},
      :options => ['Yes', 'No'],
      :responses => [],
      :survey => mock_model(Survey)
    }
  end
  
end

describe Question do
  include QuestionSpecHelper
  
  before(:each) do
    @question = Question.new
  end
  
  it "should be valid" do
    @question.attributes = valid_question_attributes
    @question.should be_valid
  end
 
  it "should have many responses" do
    Question.reflect_on_association(:responses).should_not be_nil
  end
  
  it "should have many follow_up questions" do
    Question.reflect_on_association(:child_questions).should_not be_nil
  end
  
  it "should have a parent question" do
    Question.reflect_on_association(:parent_question).should_not be_nil
  end  
  
  it "should require question text" do
    @question.attributes = valid_question_attributes.except(:text)
    @question.should have(1).error_on(:text)
  end
  
  it "should be invalid with question text longer than 1000 characters" do
    @question.attributes = valid_question_attributes.with(:text => "a" * 1001)
    @question.should have(1).error_on(:text)
  end
  
  it "should set custom questions with wage responses as required by default" do
    @question.attributes = valid_question_attributes.with(:question_type => "Pay or wage response")
    @question.valid?
    @question.required?.should == true
  end
  
  it "should not set predefined questions with wage responses as required by default" do
    @question.attributes = valid_question_attributes.with(:question_type => "Pay or wage response", :predefined_question_id => "1")
    @question.valid?
    @question.required?.should == false
  end  

  it "should determine the number of nested levels for the question when the question is a parent after saving" do
    @question.attributes = valid_question_attributes
    @question.save
    @question.level.should == 0
  end
  
  it "should determine the number of nested levels for the question when the question is a child after saving" do
    @survey = Factory.create(:survey)
    @parent_question = Factory.create(:question, :survey => @survey)
    @question.attributes = valid_question_attributes
    @question.parent_question = @parent_question
    @question.save
    @question.level.should == 1
  end
  
  it "should correctly determine the type for a question after validation if the question type changes" do
    @question.attributes = valid_question_attributes
    @question.save
    @question.question_type = "Text response"
    @question.valid?
    @question.response_type.should == "TextualResponse"
  end
  
  
  it "should yield correct report type" do
     @question.attributes = valid_question_attributes
     @question.report_type.should == 'radio'
  end
  
  it "should yield correct response class" do
     @question.attributes = valid_question_attributes
     @question.response_class.to_s.should == 'MultipleChoiceResponse'
  end
  it "should correctly determine if the question is a yes or no question" do
    @question.attributes = valid_question_attributes
    @question.yes_no?.should be_true
  end
end

describe Question, "with response" do
  before(:each) do
    @survey = Factory.create(:survey)
    @question = Factory.create(:question, :survey => @survey)
  end
  it "should return the minumimum number of responses for the response type" do
    @response = Factory.create(:numerical_response, :participation => Factory.create(:participation), :question => @question)
    @question.minimum_responses.should == @response.minimum_responses_for_report
  end 
  
  it "should be true with an adequete number of responses" do
    NumericalResponse.minimum_responses_for_report.times do
      Factory(:response, :question => @question, :participation => Factory.create(:participation))
    end
    @question.adequate_responses?.should be_true
  end
  
  it "should be false without an adequete number of responses" do
    @question.adequate_responses?.should be_false
  end
  
  it "should be true with an adequete number of responses for percentiles" do
    NumericalResponse.minimum_responses_for_percentiles.times do
      Factory(:response, :question => @question, :participation => Factory.create(:participation))
    end
    @question.adequate_responses_for_percentiles?.should be_true
  end
  
  it "should be false with an adequete number of responses for percentiles" do
    @question.adequate_responses_for_percentiles?.should be_false
  end
  
  it "should collect comments from responses for the question" do
    Factory.create(:response, :comments => "Comment for a question.", :participation => Factory.create(:participation), :question => @question)
    @question.comments.size.should > 0
  end
end

describe Question, "with options" do
  include QuestionSpecHelper
  
  before(:each) do
    @question = Question.new
    @question.attributes = valid_question_attributes.with(:response_type => 'MultipleChoiceResponse')
  end
  
  it "should be invalid without some options" do
    @question.attributes = @question.attributes.with(:options => [], :question_type => '')
    @question.should have(1).error_on(:options)
  end
end

describe Question, "that is just plain old text (like instructions)" do
  include QuestionSpecHelper
  
  before(:each) do
    @question = Question.new
    @question.attributes = valid_question_attributes.with(:response_type => nil)
  end

end
