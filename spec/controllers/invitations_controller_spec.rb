require File.dirname(__FILE__) + '/../spec_helper'

describe InvitationsController, "#route_for" do

  it "should map { :controller => 'invitations', :action => 'index' } to /invitations" do
    #route_for(:controller => "invitations", :action => "index").should == "/invitations"
  end

  it "should map { :controller => 'invitations', :action => 'new' } to /invitations/new" do
    #route_for(:controller => "invitations", :action => "new").should == "/invitations/new"
  end

  it "should map { :controller => 'invitations', :action => 'show', :id => 1 } to /invitations/1" do
    #route_for(:controller => "invitations", :action => "show", :id => 1).should == "/invitations/1"
  end

  it "should map { :controller => 'invitations', :action => 'edit', :id => 1 } to /invitations/1;edit" do
    #route_for(:controller => "invitations", :action => "edit", :id => 1).should == "/invitations/1;edit"
  end

  it "should map { :controller => 'invitations', :action => 'update', :id => 1} to /invitations/1" do
    #route_for(:controller => "invitations", :action => "update", :id => 1).should == "/invitations/1"
  end

  it "should map { :controller => 'invitations', :action => 'destroy', :id => 1} to /invitations/1" do
    #route_for(:controller => "invitations", :action => "destroy", :id => 1).should == "/invitations/1"
  end
end

describe InvitationsController, " handling GET /invitations" do
  it "should be successful"
  it "should render index template"
  it "should find all weathers"
  it "should assign the found weathers for the view"
end

describe InvitationsController, " handling GET /invitations.xml" do
  it "should be successful"
  it "should find all invitations"
  it "should render the found invitations as XML"
end

describe InvitationsController, " handling GET /invitations/1" do
  it "should be successful"
  it "should find the invitation requested"
  it "should render the show template"
  it "should assigned the found invitation to the view"
end

describe InvitationsController, " handling GET /invitations/1.xml" do
  it "should be successful"
  it "should find the invitation requested"
  it "should render the found invitation as XML"
end

describe InvitationsController, " handling GET /invitations/new" do
  it "should be successful"
  it "should render new template"
  it "should create a new invitation"
  it "should not save the new invitation"
  it "should assign the new invitation to the view"
end

describe InvitationsController, " handling GET /invitations/1/edit" do
  it "should be successful"
  it "should render the edit template"
  it "should find the invitation requested"
  it "should assign the found invitation to the view"
end

describe InvitationController, " handling POST /invitations" do
  it "should create a new invitation by type"
  it "should have a survey_id is type is 'Survey'"
  it "should have a network_id if the type is 'Network'"
  it "should redirect to the new invitation"
end

describe InvitationsController, " handling PUT /invitations/1" do
  it "should find the invitation requested"
  it "should update the selected invitation"
  it "should assign the found invitation to the view"
  it "should redirect to invitations default view"
end

describe InvitationsController, " handling DELETE /invitations/1" do
  it "should find the invitation requested"
  it "should destory the invitation requested"
  it "should redirect to the dashboard"
end
