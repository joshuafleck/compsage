require File.dirname(__FILE__) + '/../spec_helper'

describe DiscussionsController, "#route_for" do

  it "should map { :controller => 'discussions', :action => 'index' } to surveys/1/discussions" do
    #route_for(:controller => "discussions", :action => "index", :survey_id => 1) .should == "surveys/1/discussions"
  end

  it "should map { :controller => 'discussions', :action => 'new' } to surveys/1/discussions/new" do
    #route_for(:controller => "discussions", :action => "new", :survey_id => 1).should == "surveys/1/discussions/new"
  end

  it "should map { :controller => 'discussions', :action => 'edit', :id => 1 } to surveys/1/discussions/1/edit" do
    #route_for(:controller => "discussions", :action => "edit", :id => 1, :survey_id => 1).should == "surveys/1/discussions/1/edit"
  end

  it "should map { :controller => 'discussions', :action => 'update', :id => 1} to surveys/1/discussions/1" do
    #route_for(:controller => "discussions", :action => "update", :id => 1, :survey_id => 1).should == "surveys/1/discussions/1"
  end

  it "should map { :controller => 'discussions', :action => 'destroy', :id => 1} to surveys/1/discussions/1" do
    #route_for(:controller => "discussions", :action => "destroy", :id => 1, :survey_id => 1).should == "surveys/1/discussions/1"
  end

  it "should map { :controller => 'discussions', :action => 'report', :id => 1} to surveys/1/discussions/1/report" do
    #route_for(:controller => "discussions", :action => "destroy", :id => 1, :survey_id => 1).should == "surveys/1/discussions/1"
  end

end

describe DiscussionsController, " handling GET discussions" do
  it "should be successful"
  it "should render index template"
  it "should find all discussions, under the number of times reported threshold"
  it "should assign the found discussion for the view"
  it "should only render if the user is invited to, or sponsors the related survey"
end

describe DiscussionsController, " handling GET /discussions.xml" do
  it "should be successful"
  it "should find all discussion, under the number of times reported thresholds"
  it "should render the found discussions as XML"
  it "should only render if the user is invited to, or sponsors the related survey"
end

describe DiscussionsController, " handling GET /discussions/new" do
  it "should be successful"
  it "should render new template"
  it "should only render if the user is invited to, or sponsors the related survey"
end

describe DiscussionsController, " handling GET /discussions/1/edit" do
  it "should be successful"
  it "should render the edit template"
  it "should find the discussion requested"
  it "should assign the found discussion to the view"
  it "should not be when current organization is not the sponsor"
  it "should only render if the user is invited to, or sponsors the related survey"
end

describe DiscussionsController, " handling POST /discussions" do
  it "should create a new discussion"
  it "should redirect to all discussions view upon success"
  it "should flash an error upon failure"
  it "should only render if the user is invited to, or sponsors the related survey"
  it "should assign the parent discussion if this is a reply"
end

describe DiscussionsController, " handling PUT /discussions/1" do
  it "should find the discussion requested"
  it "should update the selected discussion"
  it "should assign the found discussion to the view"
  it "should redirect to the discussion page for related survey upon success"
  it "should flash an error upon failure"
  it "should error when the current organization is not the owner of current discussion"
end

describe DiscussionsController, " handling DELETE /discussions/1" do
  it "should find the discussion requested"
  it "should destory the discussion requested"
  it "should destroy the children of the discussion"
  it "should redirect discussions page for the related survey upon success"
  it "should flash an error upon failure"
  it "should error when the current organization is not the owner of current discussion"
end

describe DiscussionsController, "handling PUT /discussions/1/report" do
  it "should find the discussion requested"
  it "should increase the number of times reported"
  it "should send an email reporting the abuse when the number of times reported is greater then the threshold"
  it "should redirect to the discussion page and flash a success message upon success"
  it "should flash an error upon failure"
end
