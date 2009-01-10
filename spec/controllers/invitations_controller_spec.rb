require File.dirname(__FILE__) + '/../spec_helper'
#These specs are from the vantage point of an invitee.
describe InvitationsController, "#route_for" do

  it "should map { :controller => 'invitations', :action => 'index' } to /invitations" do
    route_for(:controller => "invitations", :action => "index").should == "/invitations"
  end

  it "should map { :controller => 'invitations', :action => 'destroy', :id => 1} to /invitations/1" do
    route_for(:controller => "invitations", :action => "destroy", :id => 1).should == "/invitations/1"    
  end

end


describe InvitationsController, " handling GET /invitations.xml" do
  
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @invitations = [mock_model(Invitation)]
    
    @current_organization.stub!(:invitations).and_return(@invitations)
    
    @invitations.stub!(:to_xml).and_return("XML")
    
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index
  end
    
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should require login" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should find all non-accepted invitations" do
    @current_organization.should_receive(:invitations).and_return(@invitations)
    do_get
  end
  
  it "should render the found invitations as XML" do
    @invitations.should_receive(:to_xml).and_return("XML")
    do_get
  end
  
end

describe InvitationsController, " handling DELETE /invitations/1" do  
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @invitation = mock_model(Invitation)
    @invitations = [@invitation]
    
    @current_organization.stub!(:invitations).and_return(@invitations)
    
    @invitations.stub!(:find).and_return(@invitation)    
    
    @invitation.stub!(:destroy).and_return(true)
    
    @params = {"id" => "1"}
    
  end
  
  def do_delete
    @request.env["HTTP_ACCEPT"] = "application/xml"
    delete :destroy, @params
  end
  
  it "should require login" do
    controller.should_receive(:login_required)
    do_delete
  end
  
  it "should find the invitation" do
    @invitations.should_receive(:find).and_return(@invitation)
    do_delete
  end
  
  it "should destroy the invitation" do
    @invitation.should_receive(:destroy)
    do_delete
  end

  
end


