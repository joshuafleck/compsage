require File.dirname(__FILE__) + '/../spec_helper'

describe ResponsesController, "#route_for" do
  
  it "should map { :controller => 'responses', :action => 'index', :survey_id => 1, :question_id => 1 } to /surveys/1/questions/1/responses" do
    route_for(:controller => "responses", :action => "index", :survey_id => 1, :question_id => 1).should == "/surveys/1/questions/1/responses"
  end
  
  it "should map { :controller => 'responses', :action => 'show', :id => 1, :survey_id => 1, :question_id => 1 } to /surveys/1/questions/1/responses/1" do
    route_for(:controller => "responses", :action => "show", :id => 1, :survey_id => 1, :question_id => 1).should == "/surveys/1/questions/1/responses/1"
  end
  
  it "should map { :controller => 'responses', :action => 'update', :id => 1, :survey_id => 1, :question_id => 1} to /surveys/1/questions/1/responses/1" do
    route_for(:controller => "responses", :action => "update", :id => 1, :survey_id => 1, :question_id => 1).should == "/surveys/1/questions/1/responses/1"
  end
  
  it "should map { :controller => 'responses', :action => 'destroy', :id => 1, :survey_id => 1, :question_id => 1} to /surveys/1/questions/1/responses/1" do
    route_for(:controller => "responses", :action => "destroy", :id => 1, :survey_id => 1, :question_id => 1).should == "/surveys/1/questions/1/responses/1"
  end
  
end

# no rhtml specs, as they're probably not needed

describe ResponsesController, "handling GET /responses/1.xml" do
  it "should be successful"
  it "should render the response as xml without the organization that made the response"
  it "should find the response requested"
end

describe ResponsesController, "handling POST /responses from xml" do
  it "should create a new response"
  it "should render an error without a question specified"
end

describe ResponsesController, "handling PUT /responses/1.xml from xml" do 
  it "should create a new response"
  it "should return an error when the response doesn't belong to the current user"
  it "should return an error when the survey is closed"
end

describe ResponsesController, "handling DELETE /responses/1.xml from xml" do
  it "should find the requested response"
  it "should destroy the specified response"
  it "should return an error when the response doesn't belong to the current user"
  it "should return an error when the survey is closed"
end