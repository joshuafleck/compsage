require File.dirname(__FILE__) + '/../spec_helper'

#specs specific to SurveyInvitationsController
describe SurveyInvitationsController, " #route for" do

    it "should map { :controller => 'invitations', :action => 'index', :survey_id => 1 } to /surveys/1/invitations" do
      route_for(:controller => "survey_invitations", :action => "index", :survey_id => 1).should == "/surveys/1/invitations"
    end

    it "should map { :controller => 'invitations', :action => 'new', :survey_id => 1 } to /surveys/1/invitations/new" do
      route_for(:controller => "survey_invitations", :action => "new", :survey_id => 1).should == "/surveys/1/invitations/new"
    end

    it "should map { :controller => 'invitations', :action => 'destroy', :id => 1, :survey_id => 1} to /surveys/1/invitations/1" do
      route_for(:controller => "survey_invitations", :action => "destroy", :id => 1, :survey_id => 1).should == "/surveys/1/invitations/1"
    end
end

describe SurveyInvitationsController, " handling GET /surveys/1/invitations" do
  before do
    @params = {:survey_id => 1}
  end
  
  def do_get
    get :index, @params
  end

  it "should be successful" do
  	do_get
  	response.should be_success
  end
  
  it "should render index template" do
  	do_get
  	response.should render_template('index')
  end
  
  it "should assign the found survey invitations for the view"
  it "should find the external survey invitations"
  it "should find all invitations"
end

describe SurveyInvitationsController, " handling GET /surveys/1/invitations.xml" do
  it "should find all survey invitations"
  it "should be successful"
  it "should render the found invitations as XML"
end


describe SurveyInvitationsController, " handling GET /surveys/1/invitations/new" do
  it "should error if requesting organization is not survey sponsor"
  it "should be successful"
  it "should render new template"
end

describe SurveyInvitationsController, " handling POST /surveys/1/invitations" do
  it "should create a new survey_invitation if the invitee exists"
  it "should create a new external_survey_invitation if the invitee does not exist"
  it "should error if requesting organization is not sponsor of the survey"
  it "should redirect to the invitation index page and flash a message regarding the success of the action"
end

describe SurveyInvitationsController, " handling DELETE /surveys/1/invitations/1" do
  it "should error if requesting organization is not sponsor"
  it "should find the invitation requested"
  it "should destroy the invitation requested"
  it "should redirect to the invitation index page"
end


  
#specs specific to NetworkInvitationsController  
describe NetworkInvitationsController, " #route for" do
    it "should map { :controller => 'invitations', :action => 'index', :network_id => 1 } to /networks/1/invitations" do
      route_for(:controller => "network_invitations", :action => "index", :network_id => 1).should == "/networks/1/invitations"
    end

    it "should map { :controller => 'invitations', :action => 'new', :network_id => 1 } to /networks/1/invitations/new" do
      route_for(:controller => "network_invitations", :action => "new", :network_id => 1).should == "/networks/1/invitations/new"
    end

    it "should map { :controller => 'invitations', :action => 'destroy', :id => 1, :network_id => 1} to /networks/1/invitations/1" do
      route_for(:controller => "network_invitations", :action => "destroy", :id => 1, :network_id => 1).should == "/networks/1/invitations/1"
    end
end

describe NetworkInvitationsController, " handling GET /networks/1/invitations" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @invitation = mock_model(Invitation)
    @invitations = [@invitation]
    @invitations_proxy = mock('Invitations Proxy', :find => @invitations)
    
    @network = mock_model(Network, :invitations => @invitations_proxy, :name => 'network')
    @network_proxy = mock('Network Proxy', :find => @network)
    
    @organization.stub!(:owned_networks).and_return(@network_proxy)
    
    @params = {:network_id => 1}
  end
  
  def do_get
    get :index, @params
  end
  
  it "should be successful" do
  	do_get
  	response.should be_success
  end
  
  it "should render index template" do
  	do_get
  	response.should render_template('index')
  end
  
  it "should find the network" do
    @network_proxy.should_receive(:find).and_return(@network)
    do_get
  end
  
  it "should find all the network's invitations" do
  	@network.should_receive(:invitations).and_return(@invitations_proxy)
  	do_get
  end
  
  it "should assign the network for the view" do
    do_get
    assigns[:network].should_not be_nil
  end
  
  it "should assign the found network invitations for the view" do
  	do_get
  	assigns[:invitations].should_not be_nil
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required).and_return(true)
    do_get
  end
end



describe NetworkInvitationsController, " handling GET /networks/1/invitations.xml" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @invitation = mock_model(Invitation)
    @invitations = [@invitation]
    @invitations.stub!(:to_xml).and_return('XML')
    @invitations_proxy = mock('Invitations Proxy', :find => @invitations)
    
    @network = mock_model(Network, :invitations => @invitations_proxy, :name => 'network')
    @network_proxy = mock('Network Proxy', :find => @network)
    
    @organization.stub!(:owned_networks).and_return(@network_proxy)
    
    @params = {:network_id => 1}
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index, @params
  end
  
  it "should be successful" do
  	do_get
  	response.should be_success
  end
  
  it "should render the found invitations as XML" do
  	do_get
  	response.body.should == "XML"
  end
  
end

describe NetworkInvitationsController, " handling GET /networks/1/invitations/new" do

  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @params = {:network_id => 1}
  end
  
  def do_get
    get :new, @params
  end
  
  it "should be successful" do
  	do_get
  	response.should be_success
  end
  
  it "should render new template" do
  	do_get
  	response.should render_template('new')
  end
  
end

describe NetworkInvitationsController, " handling POST /networks/1/invitations" do
  
  before do
    @organization = mock_model(Organization, :name => 'Inviting Org')
    login_as(@organization)
    
    @invited_organization = mock_model(Organization, :name => 'Invited Org')
    
    @invitation = mock_model(Invitation, :save => true)
    
    @invitations_proxy = mock('invitations proxy', :new => @invitation)
    @external_invitations_proxy = mock('external_invitations_proxy', :new => @invitation)
    
    @network = mock_model(Network, :invitations => @invitations_proxy, :external_invitations => @external_invitations_proxy)
    @network_proxy = mock('Network Proxy', :find => @network)
    
    @organization.stub!(:owned_networks).and_return(@network_proxy)
    
    @params = {:network_id => 1}
  end
  
  def do_post
    post :create, @params
  end
  
  it "should create a new network invitation if the invitee exists" do
  	Organization.should_receive(:find_by_email).and_return(@organization)
  	@invitations_proxy.should_receive(:new).and_return(@invitation)
  	@external_invitations_proxy.should_not_receive(:new)
  	
  	do_post
  end
  
  it "should create a new external network invitation if the invitee does not exist" do
  	Organization.should_receive(:find_by_email).and_return(nil)
  	@invitations_proxy.should_not_receive(:new)
  	@external_invitations_proxy.should_receive(:new).and_return(@invitation)
  	
  	do_post
  end
  
end

describe NetworkInvitationsController, " handling DELETE /network/1/invitations/1" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @invitation = mock_model(Invitation, :destroy => true)
    @invitations_proxy = mock('invitations proxy', :find => @invitation)
    
    @network = mock_model(Network, :invitations => @invitations_proxy)
    @network_proxy = mock('Network Proxy', :find => @network)
    
    @organization.stub!(:owned_networks).and_return(@network_proxy)
    
    @params = {:network_id => 1, :id => 1}
  end
  
  def do_delete
    delete :destroy, @params
  end
  
  it "should find the invitation requested" do
    @invitations_proxy.should_receive(:find).and_return(@invitation)
  	do_delete
  end
  
  it "should destroy the invitation requested" do
  	@invitation.should_receive(:destroy)
  	do_delete
  end
  
  it "should redirect to the invitation index page" do
  	do_delete
  	response.should redirect_to(network_invitations_path(1))
  end
end
