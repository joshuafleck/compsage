require File.dirname(__FILE__) + '/../spec_helper'

describe InvitationsController, "#route_for" do

  it "should map { :controller => 'invitations', :action => 'index' } to /invitations" do
    #route_for(:controller => "invitations", :action => "index").should == "/invitations"
  end
  
  it "should map { :controller => 'invitations', :action => 'show', :id => 1 } to /invitations/1" do
    #route_for(:controller => "invitations", :action => "show", :id => 1).should == "/invitations/1"
  end

  it "should map { :controller => 'invitations', :action => 'update', :id => 1} to /invitations/1" do
    #route_for(:controller => "invitations", :action => "update", :id => 1).should == "/invitations/1"
  end

end

describe InvitationsController, " handling GET /invitations" do
  it "should be successful"
  it "should render index template"
  it "should find all invitations"
  it "should assign the found invitations to the view"
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

describe InvitationsController, " handling PUT /invitations/1 (Network)" do
  it "should give an error is the organization requesting does not match the organization invited"
  it "should find the invitation requested"
  it "should destroy the selected invitation"
  it "should assign the organization to the network"
  it "should redirect to the show network view for associated network"
end

describe InvitationsController, " handling PUT /invitations/1 (Survey)" do
  it "should give an error is the organization requesting does not match the organization invited"
  it "should find the invitation requested"
  it "should destroy the selected invitation"
  it "should assign the organization to the survey"
  it "should redirect to the show survey view for associated survey"
end

