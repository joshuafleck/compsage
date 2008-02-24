require File.dirname(__FILE__) + '/../spec_helper'

describe SurveysController, "#route_for" do

  it "should map { :controller => 'surveys', :action => 'index' } to /surveys" do
    #route_for(:controller => "surveys", :action => "index").should == "/surveys"
  end

  it "should map { :controller => 'surveys', :action => 'new' } to /surveys/new" do
    #route_for(:controller => "surveys", :action => "new").should == "/surveys/new"
  end

  it "should map { :controller => 'surveys', :action => 'show', :id => 1 } to /surveys/1" do
    #route_for(:controller => "surveys", :action => "show", :id => 1).should == "/surveys/1"
  end

  it "should map { :controller => 'surveys', :action => 'edit', :id => 1 } to /surveys/1/edit" do
    #route_for(:controller => "surveys", :action => "edit", :id => 1).should == "/surveys/1;edit"
  end

  it "should map { :controller => 'surveys', :action => 'update', :id => 1} to /surveys/1" do
    #route_for(:controller => "surveys", :action => "update", :id => 1).should == "/surveys/1"
  end

  it "should map { :controller => 'surveys', :action => 'destroy', :id => 1} to /surveys/1" do
    #route_for(:controller => "surveys", :action => "destroy", :id => 1).should == "/surveys/1"
  end
end

describe SurveysController, " handling GET /surveys" do
  it "should be successful"
  it "should render index template"
  it "should find all survey"
  it "should assign the found surveys for the view"
  it "should only be able to get if organization has been invited"
end

describe SurveysController, " handling GET /surveys.xml" do
  it "should be successful"
  it "should find all surveys"
  it "should render the found surveys as XML"
end

describe SurveysController, " handling GET /surveys/1" do
  it "should be successful"
  it "should find the survey requested"
  it "should render the show template"
  it "should assigned the found survey to the view"
  it "should error if requesting organization is not invited or sponsor"
end

describe SurveysController, " handling GET /surveys/1.xml" do
  it "should be successful"
  it "should find the survey requested"
  it "should render the found survey as XML"
  it "should error if requesting organization is not invited or sponsor"
end

describe SurveysController, " handling GET /surveys/new" do
  it "should be successful"
  it "should render new template"
  it "should create a new survey"
  it "should not save the new survey"
  it "should assign the new survey to the view"
  it "should error if requesting organization is not invited or sponsor"

end

describe SurveysController, " handling GET /surveys/1/edit" do
  it "should be successful"
  it "should render the edit template"
  it "should find the survey requested"
  it "should assign the found survey to the view"
  it "should error if requesting organization is not sponsor"
end

describe SurveysController, " handling POST /surveys" do
  it "should create a new survey by sponsor_id"
  it "should redirect to new survey_invitation upon success"
  it "should error if requesting organization is not sponsor"
end

describe SurveysController, " handling PUT /surveys/1" do
  it "should find the survey requested"
  it "should update the selected survey"
  it "should assign the found survey to the view"
  it "should redirect to surveys default view"
  it "should error if requesting organization is not sponsor"  
end

describe SurveysController, " handling DELETE /surveys/1" do
  it "should find the survey requested"
  it "should destory the survey requested"
  it "should redirect to the index view"
  it "should error if requesting organization is not sponsor"  
end
