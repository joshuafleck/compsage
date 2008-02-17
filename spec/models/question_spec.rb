require File.dirname(__FILE__) + '/../spec_helper'

describe Question do
  before(:each) do
    @question = Question.new
  end
  
  it "should be valid"
  
  it "should be invalid without a survey"
  
  it "should have many responses"
  
  it "should require question text"
  
  it "should be invalid with question text longer than 1000 characters"
end

describe Question, "with options", :shared => true do
  
  it "should be invalid without some options"
  
  it "should save a numerical response"
  
end

describe Question, "without options with a textual response", :shared => true do
  
  it "should save a textual response"

end

describe Question, "without options with a numerical response", :shared => true do
  
  it "should save a numerical response"

  it "should be invalid if it's not a number"
  
end

describe Question, "with radio buttons" do
  
  it_should_behave_like "Question with options"
  
  it "should only accept one response"
  
  it "should be numberable"
end


describe Question, "with check boxes" do
  
  it_should_behave_like "Question with options"
  
  it "should accept multiple responses"
  
  it "should be numberable"
end

  
describe Question, "with select box" do
  
  it_should_behave_like "Question with options"
  
  it "should only accept one response"
  
  it "should be numberable"
end

describe Question, "with a text box of some sort" do
  
  it_should_behave_like "Question without options with a textual response"
  
  it "should be numberable"
  
  it "should only accept one response"
  
end

describe Question, "with numerical input box" do
  
  it_should_behave_like "Question without options with a numerical response"
  
  it "should only accept one response"
  
end


describe Question, "that is just plain old text (like instructions)" do
  
  it "should not be numberable"
  
end