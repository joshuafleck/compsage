require File.dirname(__FILE__) + '/../spec_helper'


describe QuestionsController, "#route_for" do
  
  it "should map { :controller => 'questions', :action => 'index', :survey_id => 1 } to /surveys/1/questions" do
    route_for(:controller => "questions", :action => "index", :survey_id => 1).should == "/surveys/1/questions"
  end
  
  it "should map { :controller => 'questions', :action => 'show', :id => 1, :survey_id => 1 } to /surveys/1/questions/1" do
    #route_for(:controller => "questions", :action => "show", :id => 1, :survey_id => 1).should == "/surveys/1/questions/1"
  end
  
  it "should map { :controller => 'questions', :action => 'update', :id => 1, :survey_id => 1 } to /surveys/1/questions/1" do
    #route_for(:controller => "questions", :action => "update", :id => 1, :survey_id => 1).should == "/surveys/1/questions/1"
  end
  
  it "should map { :controller => 'questions', :action => 'destroy', :id => 1, :survey_id => 1 } to /surveys/1/questions/1" do
    #route_for(:controller => "questions", :action => "destroy", :id => 1, :survey_id => 1).should == "/surveys/1/questions/1"
  end
  
end

#Questions index will be used to view the questions
describe QuestionsController, "handling GET /questions" do
  it "should render the questions index for the associated survey"
  it "should be successful"
  it "should find questions for the survey"
  it "should assign the found questions to the view"
  it "should render the questions view template"
end

describe QuestionsController, "handling GET /questions.xml" do
  it "should be successful"
  it "should find questions for the survey"
  it "should render the found questions as XML"
end


describe QuestionsController, "handling GET /questions, when survey is closed" do
  it "should redirect to the report for the survey"
  it "should flash a message clarifying that the survey is closed"
end



# These specs will not be developed until phase two
# required for more advanced question creation, instead
# of simple form we will use for phase one.

describe QuestionsController, "handling GET /questions/1.xml" do
  it "should be successful"
  it "should render the question as xml"
  it "should find the question requested"
  it "should return an error if the current organization is not invited to the survey"
  it "should return xml"
end

describe QuestionsController, "handling POST /questions from xml" do
  it "should create a new question"
  it "should return an error without a survey specified"
  it "should return an error if the current organization is not the owner of the survey"
  it "should return an error if the survey is closed"
end

describe QuestionsController, "handling PUT /questions/1.xml from xml" do 
  it "should update the specified question's attributes"
  it "should return an error if the survey is closed"
  it "should return an error when the question belongs to a survey that doesn't belong to the current organization"
end

describe QuestionsController, "handling DELETE /questions/1.xml from xml" do
  it "should find the requested question"
  it "should destroy the specified question"
  it "should return an error if the survey is closed"
  it "should return an error when the question belongs to a survey that doesn't belong to the current organization"
end