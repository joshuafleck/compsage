require File.dirname(__FILE__) + '/../spec_helper'

#specs that are shared between both SurveyInvitationController and NetworkInvitationController
#These specs are from the vantage point of a network/survey owner
describe "general invitation controller, handling GET all", :shared => true do

  it "should be successful" do
  	pending
  end
  
  it "should render index template" do
  	pending
  end
  
  it "should find all invitations" do
  	pending
  end
  
  it "should find all external_invitations" do
  	pending
  end
  
end

describe "general invitation controller, handling GET all, XML", :shared => true do

  it "should be successful" do
  	pending
  end
  
  it "should find all invitations" do
  	pending
  end
  
  it "should find all external_invitations" do
  	pending
  end
  
  it "should render the found invitations in XML" do
  	pending
  end
  
end

describe "general invitation controller, handling GET new", :shared => true do

  it "should be successful" do
  	pending
  end
  
  it "should render new template" do
  	pending
  end
  
end

describe "general invitation controller, handling POST", :shared => true do

  it "should redirect to the new invitation" do
  	pending
  end
  
  it "should notify the invitee of the new invitation via email when the invitation is internal" do
  	pending
  end
  
  it "should notify the external organization of the new invitation via email when the invitation is external" do
  	pending
  end
  
  it "should return a response regarding the success of the action if the request is XML" do
  	pending
  end
  
  it "should redirect to the invitation index page and flash a message regarding the success of the action when the request is HTML" do
  	pending
  end
  
end

describe "general invitation controller, handling DELETE", :shared => true do

  it "should find the invitation requested" do
  	pending
  end
  
  it "should destroy the invitation requested" do
  	pending
  end
  
  it "should redirect to the invitation index page" do
  	pending
  end
  
  it "should return a response regarding the success of the action if the request is XML" do
  	pending
  end
  
  it "should redirect to the invitation index page and flash a message regarding the success of the action when the request is HTML" do
  	pending
  end
  
end


#specs specific to SurveyInvitationsController
describe SurveyInvitationsController, " #route for" do

    it "should map { :controller => 'invitations', :action => 'index', :survey_id => 1 } to /surveys/1/invitations" do
      #route_for(:controller => "invitations", :action => "index", :survey_id => 1).should == "/surveys/1/invitations"
      	pending
    end

    it "should map { :controller => 'invitations', :action => 'new', :survey_id => 1 } to /surveys/1/invitations/new" do
      #route_for(:controller => "invitations", :action => "new", :survey_id => 1).should == "/surveys/1/invitations/new"
      pending
    end

    it "should map { :controller => 'invitations', :action => 'destroy', :id => 1, :survey_id => 1} to /surveys/1/invitations/1" do
      #route_for(:controller => "invitations", :action => "destroy", :id => 1, :survey_id => 1).should == "/surveys/1/invitations/1"
      pending
    end
end

describe SurveyInvitationsController, " handling GET /surveys/1/invitations" do

  it_should_behave_like "general invitation controller, handling GET all"
  
  it "should assign the found survey_invitations for the view" do
  	pending
  end
  
end

describe SurveyInvitationsController, " handling GET /surveys/1/invitations.xml" do

  it_should_behave_like "general invitation controller, handling GET all, XML"
  
  it "should find all survey_invitations" do
  	pending
  end
  
end


describe SurveyInvitationsController, " handling GET /surveys/1/invitations/new" do

  it_should_behave_like "general invitation controller, handling GET new"
  
  it "should error if requesting organization is not survey sponsor" do
  	pending
  end
  
end

describe SurveyInvitationsController, " handling POST /surveys/1/invitations" do

  it_should_behave_like "general invitation controller, handling POST"
  
  it "should create a new survey_invitation if the invitee exists" do
  	pending
  end
  
  it "should create a new external_survey_invitation if the invitee does not exist" do
  	pending
  end
  
  it "should error if requesting organization is not sponsor of the survey" do
  	pending
  end
  
end

describe SurveyInvitationsController, " handling DELETE /surveys/1/invitations/1" do

  it_should_behave_like "general invitation controller, handling DELETE"
  
  it "should error if requesting organization is not sponsor"   do
  	pending
  end
  
end


  
#specs specific to NetworkInvitationsController  
describe NetworkInvitationsController, " #route for" do

    it "should map { :controller => 'invitations', :action => 'index', :network_id => 1 } to /networks/1/invitations" do
      #route_for(:controller => "invitations", :action => "index", :network_id => 1).should == "/networks/1/invitations"
      	pending
    end

    it "should map { :controller => 'invitations', :action => 'new', :network_id => 1 } to /networks/1/invitations/new" do
      #route_for(:controller => "invitations", :action => "new", :network_id => 1).should == "/networks/1/invitations/new"
      	pending
    end

    it "should map { :controller => 'invitations', :action => 'destroy', :id => 1, :network_id => 1} to /networks/1/invitations/1" do
      #route_for(:controller => "invitations", :action => "destroy", :id => 1, :network_id => 1).should == "/networks/1/invitations/1"
      pending
    end
end

describe NetworkInvitationsController, " handling GET /networks/1/invitations" do

  it_should_behave_like "general invitation controller, handling GET all"
  
  it "should redirect to the the index page and flash an error message when the organization is not a member of the network" do
	  pending
  end
  
  it "should assign the found network_invitations for the view" do
  	pending
  end
  
end

describe NetworkInvitationsController, " handling GET /networks/1/invitations.xml" do

  it_should_behave_like "general invitation controller, handling GET all, XML"
  
  it "should return an error when the organization is not a member of the network"
  
  it "should find all network_invitations" do
  	pending
  end
  
end

describe NetworkInvitationsController, " handling GET /networks/1/invitations/new" do

  it_should_behave_like "general invitation controller, handling GET new"
  
  it "should error if requesting organization is not owner of the network" do
  	pending
  end
  
end

describe NetworkInvitationsController, " handling POST /networks/1/invitations" do

  it_should_behave_like "general invitation controller, handling POST"
  
  it "should create a new network_invitation if the invitee exists" do
  	pending
  end
  
  it "should create a new external_network_invitation if the invitee does not exist" do
  	pending
  end
  
  it "should error if requesting organization is not owner of the network" do
  	pending
  end
  
end

describe NetworkInvitationsController, " handling DELETE /network/1/invitations/1" do

  it_should_behave_like "general invitation controller, handling DELETE"
  
  it "should error if requesting organization is not owner of the network"   do
  	pending
  end
  
end
