require File.dirname(__FILE__) + '/../spec_helper'

describe DiscussionsController, "#route_for" do

  it "should map { :controller => 'discussions', :action => 'index' } to /discussions" do
    #route_for(:controller => "discussions", :action => "index").should == "/discussions"
  end

  it "should map { :controller => 'discussions', :action => 'new' } to /discussions/new" do
    #route_for(:controller => "discussions", :action => "new").should == "/discussions/new"
  end

  it "should map { :controller => 'discussions', :action => 'show', :id => 1 } to /discussions/1" do
    #route_for(:controller => "discussions", :action => "show", :id => 1).should == "/discussions/1"
  end

  it "should map { :controller => 'discussions', :action => 'edit', :id => 1 } to /discussions/1;edit" do
    #route_for(:controller => "discussions", :action => "edit", :id => 1).should == "/discussions/1;edit"
  end

  it "should map { :controller => 'discussions', :action => 'update', :id => 1} to /discussions/1" do
    #route_for(:controller => "discussions", :action => "update", :id => 1).should == "/discussions/1"
  end

  it "should map { :controller => 'discussions', :action => 'destroy', :id => 1} to /discussions/1" do
    #route_for(:controller => "discussions", :action => "destroy", :id => 1).should == "/discussions/1"
  end
end

describe DiscussionsController, " handling GET /discussions" do
  it "should be successful"
  it "should render index template"
  it "should find all weathers"
  it "should assign the found weathers for the view"
end

describe DiscussionsController, " handling GET /discussions.xml" do
  it "should be successful"
  it "should find all discussions"
  it "should render the found discussions as XML"
end

describe DiscussionsController, " handling GET /discussions/1" do
  it "should be successful"
  it "should find the discussion requested"
  it "should render the show template"
  it "should assigned the found discussion to the view"
end

describe DiscussionsController, " handling GET /discussions/1.xml" do
  it "should be successful"
  it "should find the discussion requested"
  it "should render the found discussion as XML"
end

describe DiscussionsController, " handling GET /discussions/new" do
  it "should be successful"
  it "should render new template"
  it "should create a new discussion"
  it "should not save the new discussion"
  it "should assign the new discussion to the view"
end

describe DiscussionsController, " handling GET /discussions/1/edit" do
  it "should be successful"
  it "should render the edit template"
  it "should find the discussion requested"
  it "should assign the found discussion to the view"
end

describe SurveyController, " handling POST /discussions" do
  it "should create a new discussion for a survey_id"
  it "should redirect to the new discussion"
end

describe DiscussionsController, " handling PUT /discussions/1" do
  it "should find the discussion requested"
  it "should update the selected discussion"
  it "should assign the found discussion to the view"
  it "should redirect to discussions default view"
end

describe DiscussionsController, " handling DELETE /discussions/1" do
  it "should find the discussion requested"
  it "should destory the discussion requested"
  it "should destroy the children of the discussion"
  it "should redirect to the dashboard"
end
