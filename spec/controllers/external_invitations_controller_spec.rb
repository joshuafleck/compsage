require File.dirname(__FILE__) + '/../spec_helper'
#This is for creating globa invitations
describe ExternalInvitationsController, "#route_for" do

  it "should map { :controller => 'external_invitations', :action => 'index' } to external_invitations" do
    route_for(:controller => "external_invitations", :action => "index") .should == "/external_invitations"
  end

  it "should map { :controller => 'external_invitations', :action => 'new' } to external_invitations/new" do
    route_for(:controller => "external_invitations", :action => "new").should == "/external_invitations/new"    
  end
  
end

describe ExternalInvitationsController, " handling GET /external_invitations.xml" do

  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @external_invitations_proxy = mock('external invitations proxy')
    @external_invitation = mock_model(ExternalInvitation)
    @external_invitations = [@external_invitation]
    @external_invitations.stub!(:to_xml).and_return("XML")
    @external_invitations_proxy.stub!(:find).and_return(@external_invitations)
    
    @current_organization.stub!(:sent_global_invitations).and_return(@external_invitations_proxy)
    
  end

  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index
  end

  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should be successful" do
  	do_get
  	response.should be_success
  end
  
  it "should find all external_invitations by inviter" do
  	@current_organization.should_receive(:sent_global_invitations).and_return(@external_invitations_proxy)
  	do_get
  end
  
  it "should render the found external_invitations as XML" do
  	@external_invitations.should_receive(:to_xml).and_return("XML")
  	do_get
  end
  
end

describe ExternalInvitationsController, " handling POST /external_invitations.xml" do

  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @external_invitation = mock_model(ExternalInvitation, :save => true)
    @external_invitations_proxy = mock('external invitations proxy')
    
    @current_organization.stub!(:sent_global_invitations).and_return(@external_invitations_proxy)
    @external_invitations_proxy.stub!(:new).and_return(@external_invitation)
    
    Organization.stub!(:find_by_email).and_return(nil)
    
    @params = { :invitation => { :email => "test@test.com" } }
  end

  def do_post
    @request.env["HTTP_ACCEPT"] = "application/xml"
    post :create, @params
  end

  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post
  end
  
  it "should create a new external_invitation"  do
  	@external_invitations_proxy.should_receive(:new).and_return(@external_invitation)
  	do_post
  end
  
end

