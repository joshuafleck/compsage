require File.dirname(__FILE__) + '/../spec_helper'
#These specs are from the vantage point of an invitee.
describe InvitationsController, "#route_for" do

  it "should map { :controller => 'invitations', :action => 'index' } to /invitations" do
    #route_for(:controller => "invitations", :action => "index").should == "/invitations"
    pending
  end
  
  it "should map { :controller => 'invitations', :action => 'show', :id => 1 } to /invitations/1" do
    #route_for(:controller => "invitations", :action => "show", :id => 1).should == "/invitations/1"
    pending
  end

  it "should map { :controller => 'invitations', :action => 'destroy', :id => 1} to /invitations/1" do
    #route_for(:controller => "invitations", :action => "destroy", :id => 1).should == "/invitations/1"
    pending
  end

end

describe InvitationsController, " handling GET /invitations" do

  it "should be successful" do
    pending
  end
  
  it "should render index template" do
    pending
  end
  
  it "should find all non-accepted invitations" do
    pending
  end
  
  it "should assign the found invitations to the view" do
    pending
  end
  
end

describe InvitationsController, " handling GET /invitations.xml" do

  it "should be successful" do
    pending
  end
  
  it "should find all non-accepted invitations" do
    pending
  end
  
  it "should render the found invitations as XML" do
    pending
  end
  
end

describe InvitationsController, " handling GET /invitations/1" do

  it "should be successful" do
    pending
  end
  
  it "should find the invitation requested" do
    pending
  end
  
  it "should render the show template" do
    pending
  end
  
  it "should assigned the found invitation to the view" do
    pending
  end
  
end

describe InvitationsController, " handling GET /invitations/1.xml" do

  it "should be successful" do
    pending
  end
  
  it "should find the invitation requested" do
    pending
  end
  
  it "should render the found invitation as XML" do
    pending
  end
  
end

describe InvitationsController, " handling DELETE /invitations/1" do  

  it "should error if requesting organization is not the invitee"  do
    pending
  end
   
  it "should error if the invitation was already accepted"  do
    pending
  end
   
  it "should find the invitation" do
    pending
  end
  
  it "should destroy the invitation" do
    pending
  end
  
  it "should return a response regarding the success of the action when the request is XML" do
    pending
  end
  
  describe "when the request is HTML" do

    it "should redirect to the network index" do
      pending    
    end
    
    it "should flash a message regarding the success of the action" do
      pending    
    end
  
  end
  
end

#describe InvitationsController, " handling PUT /invitations/1 (Network)" do
#  it "should give an error is the organization requesting does not match the organization invited"
#  it "should find the invitation requested"
#  it "should destroy the selected invitation"
#  it "should assign the organization to the network"
#  it "should redirect to the show network view for associated network"
#end

#describe InvitationsController, " handling PUT /invitations/1 (Survey)" do
#  it "should give an error is the organization requesting does not match the organization invited"
#  it "should find the invitation requested"
#  #it "should destroy the selected invitation" - I don't think this spec is valid anymore- JF
#  it "should assign the organization to the survey"
#  it "should redirect to the show survey view for associated survey"
#end

