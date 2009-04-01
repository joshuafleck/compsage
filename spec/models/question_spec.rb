require File.dirname(__FILE__) + '/../spec_helper'

module QuestionSpecHelper

  def valid_question_attributes
    {
      :text => "What is the meaning of life?",
      :position => 1,
      :response_type => "MultipleChoiceResponse",
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
  
  it "should require question text" do
    @question.attributes = valid_question_attributes.except(:text)
    @question.should have(1).error_on(:text)
  end
  
  it "should be invalid with question text longer than 1000 characters" do
    @question.attributes = valid_question_attributes.with(:text => "a" * 1001)
    @question.should have(1).error_on(:text)
  end
end

describe Question, "with options" do
  include QuestionSpecHelper
  
  before(:each) do
    @question = Question.new
    @question.attributes = valid_question_attributes.with(:response_type => 'MultipleChoiceResponse')
  end
  
  it "should be invalid without some options" do
    @question.attributes = @question.attributes.with(:options => [])
    @question.should have(1).error_on(:options)
  end
end

describe Question, "that is just plain old text (like instructions)" do
  include QuestionSpecHelper
  
  before(:each) do
    @question = Question.new
    @question.attributes = valid_question_attributes.with(:response_type => nil)
  end

  it "should not be answerable" do
    @question.should_not be_answerable
  end
end
