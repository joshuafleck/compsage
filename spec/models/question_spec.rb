require File.dirname(__FILE__) + '/../spec_helper'

module QuestionSpecHelper

  def valid_question_attributes
    {
      :text => "What is the meaning of life?",
      :position => 1,
      :question_type => "radio",
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
  
  it "should be invalid without a survey" do
    @question.attributes = valid_question_attributes.except(:survey)
    @question.should have(1).error_on(:survey)
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

describe Question, "with options", :shared => true do
  include QuestionSpecHelper
  
  before(:each) do
    @question = Question.new
    @question.attributes = valid_question_attributes.with(:question_type => 'checkbox')
  end
  
  it "should be invalid without some options" do
    @question.attributes = @question.attributes.with(:options => [])
    @question.should have(1).error_on(:options)
  end
  
  it "should not save a numerical response" do
    @question.should_not be_numerical_response
  end
  
  it "should be answerable" do
    @question.should be_answerable
  end
end

describe Question, "without options with a textual response", :shared => true do
  include QuestionSpecHelper
  
  before(:each) do
    @question = Question.new
    @question.attributes = valid_question_attributes.with(:question_type => 'text_area')
  end  
  it "should save a textual response" do
    @question.should_not be_numerical_response
  end
  
  it "should be answerable" do
    @question.should be_answerable
  end

end

describe Question, "without options with a numerical response", :shared => true do
  include QuestionSpecHelper
  
  before(:each) do
    @question = Question.new
    @question.attributes = valid_question_attributes.with(:question_type => 'numerical_field')
  end
  it "should save a numerical response" do
    @question.should be_numerical_response
  end

  it "should be invalid if it's not a number" #should this be handled by response model?
  
  it "should be answerable" do
    @question.should be_answerable
  end
  
end

describe Question, "with radio buttons" do
  
  it_should_behave_like "Question with options"
  
  it "should only accept one response"
  
end


describe Question, "with check boxes" do
  
  it_should_behave_like "Question with options"
  
  it "should accept multiple responses"
  
end

  
describe Question, "with select box" do
  
  it_should_behave_like "Question with options"
  
  it "should only accept one response"
end

describe Question, "with a text box of some sort" do
  
  it_should_behave_like "Question without options with a textual response"
  
  it "should only accept one response"
  
end

describe Question, "with numerical input box" do
  
  it_should_behave_like "Question without options with a numerical response"
  
  it "should only accept one response"
  
end


describe Question, "that is just plain old text (like instructions)" do
  include QuestionSpecHelper
  
  before(:each) do
    @question = Question.new
    @question.attributes = valid_question_attributes.with(:question_type => 'text')
  end
  it "should not be answerable" do
    @question.should_not be_answerable
  end
  
end