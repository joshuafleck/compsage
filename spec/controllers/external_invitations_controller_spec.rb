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


describe ExternalInvitationsController, " handling GET external_invitations" do

  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @external_invitation = mock_model(ExternalInvitation)
    @external_invitations = [@external_invitation]
    
    @current_organization.stub!(:sent_global_invitations).and_return(@external_invitations)
    
  end

  def do_get
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
  
  it "should render show template" do
  	do_get
  	response.should render_template('index')
  end
  
  it "should find all external_invitations by inviter" do
  	@current_organization.should_receive(:sent_global_invitations).and_return(@external_invitations)
  	do_get
  end
  
  it "should assign the found external_invitations for the view" do
  	do_get
  	assigns[:external_invitations].should eql(@external_invitations)
  end
  
end

describe ExternalInvitationsController, " handling GET /external_invitations.xml" do

  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @external_invitation = mock_model(ExternalInvitation)
    @external_invitations = [@external_invitation]
    @external_invitations.stub!(:to_xml).and_return("XML")
    
    @current_organization.stub!(:sent_global_invitations).and_return(@external_invitations)
    
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
  	@current_organization.should_receive(:sent_global_invitations).and_return(@external_invitations)
  	do_get
  end
  
  it "should render the found external_invitations as XML" do
  	@external_invitations.should_receive(:to_xml).and_return("XML")
  	do_get
  end
  
end

describe ExternalInvitationsController, " handling GET /external_invitations/new" do

  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @external_invitation = mock_model(ExternalInvitation)
    @external_invitations = [@external_invitation]
    
    @current_organization.stub!(:sent_global_invitations).and_return(@external_invitations)
    ExternalInvitation.stub!(:new).and_return(@external_invitation)
    
  end

  def do_get
    get :new
  end

  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should be successful" do
  	do_get
  	response.should be_success
  end
  
  it "should render new template" do
  	do_get
  	response.should render_template('new')
  end
  it "should assign the new external_invitation for the view" do
  	do_get
  	assigns[:external_invitation].should eql(@external_invitation)
  end
  
end

describe ExternalInvitationsController, " handling POST /external_invitations" do

  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @external_invitation = mock_model(ExternalInvitation, :save => true)
    @external_invitations_proxy = mock('external invitations proxy')
    
    @current_organization.stub!(:sent_global_invitations).and_return(@external_invitations_proxy)
    @external_invitations_proxy.stub!(:new).and_return(@external_invitation)
    
  end

  def do_post
    post :create
  end

  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post
  end
  
  it "should create a new external_invitation"  do
  	@external_invitations_proxy.should_receive(:new).and_return(@external_invitation)
  	do_post
  end
  
  it "should notify the external organization of the invitation via email" do
  	pending
  end
  
  it "should redirect to the dashboard and flash a message regarding the success of the action when the request is HTML" do
  	do_post
  	response.should redirect_to(external_invitations_path)
  	flash[:notice].should eql("Your invitation was created successfully.")
  end
  
end
  
describe ExternalInvitationsController, " handling POST /external_invitations with error" do

  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @external_invitation = mock_model(ExternalInvitation, :save => false)
    @external_invitations_proxy = mock('external invitations proxy')
    
    @current_organization.stub!(:sent_global_invitations).and_return(@external_invitations_proxy)
    @external_invitations_proxy.stub!(:new).and_return(@external_invitation)
    
  end

  def do_post
    post :create
  end
  
  it "should redirect to the new view when the request is HTML" do
  	do_post
  	response.should render_template('new')
  end
  
end
