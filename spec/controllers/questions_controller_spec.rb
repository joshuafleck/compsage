require File.dirname(__FILE__) + '/../spec_helper'


describe QuestionsController, "#route_for" do
  
  it "should map { :controller => 'questions', :action => 'index', :survey_id => 1 } to /surveys/1/questions" do
    route_for(:controller => "questions", :action => "index", :survey_id => 1).should == "/surveys/1/questions"
  end
  
  it "should map { :controller => 'questions', :action => 'show', :id => 1, :survey_id => 1 } to /surveys/1/questions/1" do
    route_for(:controller => "questions", :action => "show", :id => 1, :survey_id => 1).should == "/surveys/1/questions/1"
  end
  
  it "should map { :controller => 'questions', :action => 'update', :id => 1, :survey_id => 1 } to /surveys/1/questions/1" do
    route_for(:controller => "questions", :action => "update", :id => 1, :survey_id => 1).should == "/surveys/1/questions/1"
  end
  
  it "should map { :controller => 'questions', :action => 'destroy', :id => 1, :survey_id => 1 } to /surveys/1/questions/1" do
    route_for(:controller => "questions", :action => "destroy", :id => 1, :survey_id => 1).should == "/surveys/1/questions/1"
  end
  
end

# no rhtml specs, as they're probably not needed

describe QuestionsController, "handling GET /questions/1.xml" do
  it "should be successful"
  it "should render the question as xml"
  it "should find the question requested"
  it "should return xml"
end

describe QuestionsController, "handling POST /questions from xml" do
  it "should create a new question"
  it "should render an error without a survey specified"
  it "should return an error if the survey is closed"
  it "should return an error if current organizatin is not invited to survey"
end

describe QuestionsController, "handling PUT /questions/1.xml from xml" do 
  it "should create a new question"
  it "should return an error when the question belongs to a survey that doesn't belong to the current organization"
end

describe QuestionsController, "handling DELETE /questions/1.xml from xml" do
  it "should find the requested question"
  it "should destroy the specified question"
  it "should return an error when the question belongs to a survey that doesn't belong to the current organization"
end