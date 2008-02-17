require File.dirname(__FILE__) + '/../spec_helper'

describe NetworkInvitationsController, " #route for" do

    it "should map { :controller => 'invitations', :action => 'index', :network_id => 1 } to /networks/1/invitations" do
      #route_for(:controller => "invitations", :action => "index", :network_id => 1).should == "/networks/1/invitations"
    end

    it "should map { :controller => 'invitations', :action => 'new', :network_id => 1 } to /networks/1/invitations/new" do
      #route_for(:controller => "invitations", :action => "new", :network_id => 1).should == "/networks/1/invitations/new"
    end

    it "should map { :controller => 'invitations', :action => 'show', :id => 1, :network_id => 1 } to /networks/1/invitations/1" do
      #route_for(:controller => "invitations", :action => "show", :id => 1, :network_id => 1).should == "/networks/1/invitations/1"
    end

    it "should map { :controller => 'invitations', :action => 'update', :id => 1, :network_id => 1} to /networks/1/invitations/1" do
      #route_for(:controller => "invitations", :action => "update", :id => 1, :network_id => 1).should == "/networks/1/invitations/1"
    end

    it "should map { :controller => 'invitations', :action => 'destroy', :id => 1, :network_id => 1} to /networks/1/invitations/1" do
      #route_for(:controller => "invitations", :action => "destroy", :id => 1, :network_id => 1).should == "/networks/1/invitations/1"
    end
  end

  describe NetworkInvitationsController, " handling GET /networks/1/invitations" do
    it "should be successful"
    it "should render index template"
    it "should find all invitations"
    it "should assign the found network_invitations for the view"
    it "should only be able to get if organization has been invited"
  end

  describe NetworkInvitationsController, " handling GET /networks/1/invitations.xml" do
    it "should be successful"
    it "should find the all network_invitations"
    it "should render the found network_invitation as XML"
  end

  describe NetworkInvitationsController, " handling GET /networks/1/invitations/1" do
    it "should be successful"
    it "should find the specified network_invitation"
    it "should render the show template"
    it "should assigned the found invitation to the view"
    it "should error if requesting if organization is not invited or sponsor"
  end

  describe NetworkInvitationsController, " handling GET /networks/1/invitations/1.xml" do
    it "should be successful"
    it "should find the invitation requested"
    it "should render the found invitation as XML"
    it "should error if requesting organization is not invited or sponsor"
  end

  describe NetworkInvitationsController, " handling GET /networks/1/invitations/new" do
    it "should be successful"
    it "should render new template"
    it "should error if requesting organization is not survey sponsor"  
  end

  describe NetworkInvitationsController, " handling POST /networks/1/invitations" do
    it "should create a new invitation by sponsor_id"
    it "should redirect to the new invitation"
    it "should error if requesting organization is not sponsor"
  end

  describe NetworkInvitationsController, " handling PUT /networks/1/invitations/1" do
    it "should find the invitation requested"
    it "should update the selected invitation"
    it "should assign the found invitation to the view"
    it "should redirect to network_invitations default view"
    it "should error if requesting organization is not sponsor"  
  end

  describe NetworkInvitationsController, " handling DELETE /networks/1/invitations/1" do
    it "should find the invitation requested"
    it "should destory the invitation requested"
    it "should redirect to the dashboard"
    it "should error if requesting organization is not sponsor"  
  end

end
