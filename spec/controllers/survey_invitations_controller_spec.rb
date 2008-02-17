require File.dirname(__FILE__) + '/../spec_helper'

describe NetworkInvitationsController, " #route for" do

    it "should map { :controller => 'invitations', :action => 'index', :survey_id => 1 } to /surveys/1/invitations" do
      #route_for(:controller => "invitations", :action => "index", :survey_id => 1).should == "/surveys/1/invitations"
    end

    it "should map { :controller => 'invitations', :action => 'new', :survey_id => 1 } to /surveys/1/invitations/new" do
      #route_for(:controller => "invitations", :action => "new", :survey_id => 1).should == "/surveys/1/invitations/new"
    end

    it "should map { :controller => 'invitations', :action => 'show', :id => 1, :survey_id => 1 } to /surveys/1/invitations/1" do
      #route_for(:controller => "invitations", :action => "show", :id => 1, :survey_id => 1).should == "/surveys/1/invitations/1"
    end

    it "should map { :controller => 'invitations', :action => 'update', :id => 1, :survey_id => 1} to /surveys/1/invitations/1" do
      #route_for(:controller => "invitations", :action => "update", :id => 1, :survey_id => 1).should == "/surveys/1/invitations/1"
    end

    it "should map { :controller => 'invitations', :action => 'destroy', :id => 1, :survey_id => 1} to /surveys/1/invitations/1" do
      #route_for(:controller => "invitations", :action => "destroy", :id => 1, :survey_id => 1).should == "/surveys/1/invitations/1"
    end
  end

  describe NetworkInvitationsController, " handling GET /surveys/1/invitations" do
    it "should be successful"
    it "should render index template"
    it "should find all invitation"
    it "should assign the found survey_invitations for the view"
    it "should only be able to get if organization has been invited"
  end

  describe NetworkInvitationsController, " handling GET /surveys/1/invitations.xml" do
    it "should be successful"
    it "should find all survey_invitations"
    it "should render the found survey_invitations as XML"
  end

  describe NetworkInvitationsController, " handling GET /surveys/1/invitations/1" do
    it "should be successful"
    it "should find the invitation requested"
    it "should render the show template"
    it "should assigned the found invitation to the view"
    it "should error if requesting organization is not invited or sponsor"
  end

  describe NetworkInvitationsController, " handling GET /surveys/1/invitations/1.xml" do
    it "should be successful"
    it "should find the invitation requested"
    it "should render the found invitation as XML"
    it "should error if requesting organization is not invitee or inviter"
  end

  describe NetworkInvitationsController, " handling GET /surveys/1/invitations/new" do
    it "should be successful"
    it "should render new template"
    it "should create a new invitation"
    it "should not save the new invitation"
    it "should assign the new invitation to the view"
    it "should error if requesting organization is not invitee or inviter"  
  end

  describe NetworkInvitationsController, " handling POST /surveys/1/invitations" do
    it "should create a new invitation by sponsor_id"
    it "should redirect to the new invitation"
    it "should error if requesting organization is not sponsor"
  end

  describe NetworkInvitationsController, " handling PUT /surveys/1/invitations/1" do
    it "should find the invitation requested"
    it "should update the selected invitation"
    it "should assign the found invitation to the view"
    it "should redirect to survey_invitations default view"
    it "should error if requesting organization is not sponsor"  
  end

  describe NetworkInvitationsController, " handling DELETE /surveys/1/invitations/1" do
    it "should find the invitation requested"
    it "should destory the invitation requested"
    it "should redirect to the dashboard"
    it "should error if requesting organization is not sponsor"  
  end
