require File.dirname(__FILE__) + '/../spec_helper'

#specs that are shared between both SurveyInvitationController and NetworkInvitationController

describe "general invitation controller, handling GET all", :shared => true do
  it "should be successful"
  it "should render index template"
  it "should find all invitations"
  it "should only be able to get if organization has been invited"
end

describe "general invitation controller, handling GET all, XML", :shared => true do
  it "should be successful"
  it "should find all invitations"
  it "should only be able to get if organization has been invited"
  it "should render the found invitations in XML"
end

describe "general invitation controller, handling GET one", :shared => true do
  it "should be successful"
  it "should render the show template"
  it "should assigned the found invitation to the view"
  it "should error if requesting organization is not inviter or invitee"  
end

describe "general invitation controller, handling GET one, XML", :shared => true do
  it "should be successful"
  it "should error if requesting organization is not inviter or invitee"
  it "should render the found invitations as XML"
end

describe "general invitation controller, handling GET new", :shared => true do
  it "should be successful"
  it "should render new template"
end

describe "general invitation controller, handling POST", :shared => true do
  it "should redirect to the new invitation"
end

describe "general invitation controller, handling PUT", :shared => true do
  it "should find the invitation requested"
  it "should update the selected invitation"
  it "should assign the found invitation to the view"
end

describe "general invitation controller, handling DELETE", :shared => true do
  it "should find the invitation requested"
  it "should destory the invitation requested"
  it "should redirect to the dashboard"
end


#specs specific to SurveyInvitationsController
describe SurveyInvitationsController, " #route for" do

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

describe SurveyInvitationsController, " handling GET /surveys/1/invitations" do
  it_should_behave_like "general invitation controller, handling GET all"
  it "should assign the found survey_invitations for the view"
end

describe SurveyInvitationsController, " handling GET /surveys/1/invitations.xml" do
  it_should_behave_like "general invitation controller, handling GET all, XML"
  it "should find all survey_invitations"
end

describe SurveyInvitationsController, " handling GET /surveys/1/invitations/1" do
  it_should_behave_like "general invitation controller, handling GET one"
  it "should find the survey_invitation requested"
end

describe SurveyInvitationsController, " handling GET /surveys/1/invitations/1.xml" do
  it_should_behave_like "general invitation controller, handling GET one, XML"
  it "should find the survey_invitation requested"
end

describe SurveyInvitationsController, " handling GET /networks/1/invitations/new" do
  it_should_behave_like "general invitation controller, handling GET new"
  it "should error if requesting organization is not survey sponsor"  
end

describe SurveyInvitationsController, " handling POST /surveys/1/invitations" do
  it_should_behave_like "general invitation controller, handling POST"
  it "should create a new invitation by sponsor_id"
  it "should error if requesting organization is not sponsor of the survey"
end

describe SurveyInvitationsController, " handling PUT /surveys/1/invitations/1" do
  it_should_behave_like "general invitation controller, handling PUT"
  it "should redirect to survey_invitations default view"
  it "should error if requesting organization is not sponsor"  
end

describe SurveyInvitationsController, " handling DELETE /surveys/1/invitations/1" do
  it_should_behave_like "general invitation controller, handling DELETE"
  it "should error if requesting organization is not sponsor"  
end


  
#specs specific to NetworkInvitationsController  
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
  it_should_behave_like "general invitation controller, handling GET all"
  it "should assign the found network_invitations for the view"
end

describe NetworkInvitationsController, " handling GET /networks/1/invitations.xml" do
  it_should_behave_like "general invitation controller, handling GET all, XML"
  it "should find all network_invitations"
end

describe NetworkInvitationsController, " handling GET /networks/1/invitations/1" do
  it_should_behave_like "general invitation controller, handling GET one"
  it "should find the network_invitation requested"
end

describe NetworkInvitationsController, " handling GET /networks/1/invitations/1.xml" do
  it_should_behave_like "general invitation controller, handling GET one, XML"
  it "should find the network_invitation requested"
end

describe NetworkInvitationsController, " handling GET /networks/1/invitations/new" do
  it_should_behave_like "general invitation controller, handling GET new"
  it "should error if requesting organization is not owner of the network"  
end

describe NetworkInvitationsController, " handling POST /networks/1/invitations" do
  it_should_behave_like "general invitation controller, handling POST"
  it "should create a new invitation by owner_id"
  it "should error if requesting organization is not owner of the network"
end

describe NetworkInvitationsController, " handling PUT /networks/1/invitations/1" do
  it_should_behave_like "general invitation controller, handling PUT"
  it "should redirect to network_invitations default view"
  it "should error if requesting organization is not owner of the network"  
end

describe NetworkInvitationsController, " handling DELETE /network/1/invitations/1" do
  it_should_behave_like "general invitation controller, handling DELETE"
  it "should error if requesting organization is not owner of the network"  
end