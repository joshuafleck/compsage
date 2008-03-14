require File.dirname(__FILE__) + '/../spec_helper'

describe SurveysController, "#route_for" do

  it "should map { :controller => 'surveys', :action => 'index' } to /surveys" do
    #route_for(:controller => "surveys", :action => "index").should == "/surveys"
  end
  
  it "should map { :controller => 'surveys', :action => 'search' } to /search" do
    #route_for(:controller => "surveys", :action => "index").should == "/surveys"
  end

  it "should map { :controller => 'surveys', :action => 'new' } to /surveys/new" do
    #route_for(:controller => "surveys", :action => "new").should == "/surveys/new"
  end

  it "should map { :controller => 'surveys', :action => 'show', :id => 1 } to /surveys/1" do
    #route_for(:controller => "surveys", :action => "show", :id => 1).should == "/surveys/1"
  end

  it "should map { :controller => 'surveys', :action => 'edit', :id => 1 } to /surveys/1/edit" do
    #route_for(:controller => "surveys", :action => "edit", :id => 1).should == "/surveys/1/edit"
  end

  it "should map { :controller => 'surveys', :action => 'update', :id => 1} to /surveys/1" do
    #route_for(:controller => "surveys", :action => "update", :id => 1).should == "/surveys/1"
  end
end

describe SurveysController, " handling GET /surveys" do
  it "should be successful"
  it "should render index template"
  it "should find all surveys for which the user has participated, been invited, or sponsored"
  it "should assign the found surveys for the view"
end

describe SurveysController, " handling GET /surveys.xml" do
  it "should be successful"
  it "should find all surveys for which the user has participated, been invited, or sponsored"
  it "should render the found surveys as XML"
end

describe SurveysController, " handling GET /surveys/1" do
  it "should be successful"
  it "should find the survey requested"
  it "should render the show template"
  it "should assign the found survey to the view"
  it "should redirect to the report for the selected survey if the survey is closed"
end

describe SurveysController, " handling GET /surveys/1.xml" do
  it "should be successful"
  it "should find the survey requested"
  it "should render the found survey as XML"
end

describe SurveysController, " handling GET /surveys/new" do
  it "should be successful"
  it "should render new template"
  it "should error if the organization is in private mode"
end

describe SurveysController, " handling GET /surveys/1/edit" do
  it "should be successful"
  it "should render the edit template"
  it "should find the survey requested"
  it "should assign the found survey to the view"
  it "should error if requesting organization is not the sponsor"
end

describe SurveysController, " handling POST /surveys" do
  it "should create a new survey"
  it "should redirect to the invitation show page upon success"
  it "should flash an error message upon failure"
  it "should error if the organization is in private mode"
end

describe SurveysController, " handling PUT /surveys/1" do
  it "should find the survey requested"
  it "should update the selected survey"
  it "should assign the found survey to the view"
  it "should redirect to the show view page for this survey upon success"
  it "should flash an error mesage upon failure"
  it "should error if requesting organization is not the sponsor"  
end

describe SurveysController, "handling GET /surveys/search" do
  it "should search the users surveys"
  it "should find surveys by title"
  it "should find surveys by description"
  it "should assign found surveys to the view"
end

describe SurveysController, "handling GET /surveys/search.xml" do
  it "should search the users surveys"
  it "should find surveys by title"
  it "should find surveys by description"
  it "should render the found surveys in XML"
end

