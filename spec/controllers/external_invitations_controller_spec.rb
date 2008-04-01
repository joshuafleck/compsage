require File.dirname(__FILE__) + '/../spec_helper'
#This is for creating globa invitations
describe ExternalInvitationsController, "#route_for" do

  it "should map { :controller => 'external_invitations', :action => 'index' } to external_invitations" do
    #route_for(:controller => "external_invitations", :action => "index") .should == "external_invitations"
    pending
  end

  it "should map { :controller => 'external_invitations', :action => 'new' } to external_invitations/new" do
    #route_for(:controller => "external_invitations", :action => "new").should == "external_invitations/new"
    pending
  end
  
end


describe ExternalInvitationsController, " handling GET external_invitations" do

  it "should be successful" do
  	pending
  end
  
  it "should render index template" do
  	pending
  end
  
  it "should find all external_invitations by inviter" do
  	pending
  end
  
  it "should assign the found external_invitations for the view" do
  	pending
  end
  
end

describe ExternalInvitationsController, " handling GET /external_invitations.xml" do

  it "should be successful" do
  	pending
  end
  
  it "should find all external_invitations by inviter" do
  	pending
  end
  
  it "should render the found external_invitations as XML" do
  	pending
  end
  
end

describe ExternalInvitationsController, " handling GET /external_invitations/new" do

  it "should be successful" do
  	pending
  end
  
  it "should render new template" do
  	pending
  end
  
end

describe ExternalInvitationsController, " handling POST /external_invitations" do

  it "should create a new external_invitation"  do
  	pending
  end
  
  it "should notify the external organization of the invitation via email" do
  	pending
  end
  
  it "should return a response regarding the success of the action when the reuest is xml" do
  	pending
  end
  
  it "should redirect to the dashboard and flash a message regarding the success of the action when the request is HTML" do
  	pending
  end
  
end
  

