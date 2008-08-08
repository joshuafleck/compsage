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
    
    it "should map { :controller => 'invitations', :action => 'create_with_network', :survey_id => 1} to /surveys/1/invitations/create_with_network" do
      route_for(:controller => "survey_invitations", :action => "create_with_network", :survey_id => 1).should == "/surveys/1/invitations/create_with_network"
    end
end

describe SurveyInvitationsController, " handling GET /surveys/1/invitations" do

  before do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @invitation = mock_model(SurveyInvitation, :id => 1, :inviter => @current_organization)
    @invitations_proxy = mock('invitations proxy')
    @invitations_proxy.stub!(:find).and_return(@invitation)
    
    @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => @current_organization, :job_title => "test", :invitations => @invitations_proxy, :external_invitations => @invitations_proxy)
    @surveys_proxy = mock('surveys proxy')
    @surveys_proxy.stub!(:find).and_return(@survey)
    
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    
    @params = {:survey_id => 1}
  end
  
  def do_get
    get :index, @params
  end

  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should be successful" do
  	do_get
  	response.should be_success
  end
  
  it "should render index template" do
  	do_get
  	response.should render_template('index')
  end
  
  it "should assign the found survey invitations for the view" do    
    do_get
    assigns(:invitations).should equal(@invitation)
   end
   
  it "should find the external survey invitations" do
    @survey.should_receive(:external_invitations).and_return(@invitations_proxy)
    do_get
   end
   
  it "should find all invitations" do
    @survey.should_receive(:invitations).and_return(@invitations_proxy)
    do_get
  end
      
  it "should error if requesting organization is not survey sponsor" do
    @current_organization.should_receive(:sponsored_surveys).and_return(@surveys_proxy)
    do_get
  end
   
end

describe SurveyInvitationsController, " handling GET /surveys/1/invitations.xml" do

 before do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @invitation = mock_model(SurveyInvitation, :id => 1, :inviter => @current_organization, :to_xml => 'XML')
    @invitations = [@invitation]
    @invitations_proxy = mock('invitations proxy')
    @invitations_proxy.stub!(:find).and_return(@invitations)
    
    @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => @current_organization, :job_title => "test", :invitations => @invitations_proxy, :external_invitations => @invitations_proxy)
    @surveys_proxy = mock('surveys proxy')
    @surveys_proxy.stub!(:find).and_return(@survey)
    
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    
    @params = {:survey_id => 1}
  end
 
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
   
  it "should find all survey invitations" do
    @survey.should_receive(:invitations).and_return(@invitations_proxy)
    do_get
   end
   
  it "should be successful" do
  	do_get
  	response.should be_success
   end
   
  it "should render the found invitations as XML" do
    @invitation.should_receive(:to_xml).at_least(:once).and_return("XML")
    do_get
   end
   
end

describe SurveyInvitationsController, " handling POST /surveys/1/invitations with internal invitation" do

 before do
    @current_organization = mock_model(Organization, :name => "test")
    login_as(@current_organization)
    
    @invitation = mock_model(SurveyInvitation, :id => 1, :inviter => @current_organization, :to_xml => 'XML', :save => true)
    @invitations_proxy = mock('invitations proxy')
    @invitations_proxy.stub!(:find).and_return(@invitation)
    
    @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => @current_organization, :job_title => "test", :invitations => @invitations_proxy)
    @surveys_proxy = mock('surveys proxy')
    @surveys_proxy.stub!(:find).and_return(@survey)
    
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    @current_organization.stub!(:survey_invitations).and_return([])
    Organization.stub!(:find_by_email).and_return(@current_organization)
    
    @surveys_proxy.stub!(:running).and_return(@surveys_proxy)
    @invitations_proxy.stub!(:new).and_return(@invitation)
    
    @params = {:survey_id => 1, :invitation => {:email => "test", :name => "test"}}
  end
 
  def do_post
    post :create, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post
  end
  
  it "should check to see if the invitee exists" do
    Organization.should_receive(:find_by_email).with(@params[:invitation][:email]).and_return(@current_organization)
    do_post
  end
   
  it "should create a new survey_invitation if the invitee exists" do
    @invitations_proxy.should_receive(:new).with(:invitee => @current_organization, :inviter => @current_organization).and_return(@invitation)
    do_post
  end
     
  it "should require the organization is the sponsor of the survey" do
    @current_organization.should_receive(:sponsored_surveys).and_return(@surveys_proxy)
    do_post
  end
   
  it "should redirect to the invitation index page and flash a message regarding the success of the action" do
    do_post
    flash[:message].should eql("Invitation sent to #{@current_organization.name}.")
    response.should redirect_to('surveys/1/invitations')
  end
   
end

describe SurveyInvitationsController, " handling GET /surveys/1/create_with_network" do

 before do
    @current_organization = mock_model(Organization, :name => "test")
    login_as(@current_organization)
      
    @invitations_proxy = mock('invitations proxy')
    
    @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => @current_organization, :job_title => "test", :invitations => @invitations_proxy)
    @surveys_proxy = mock('surveys proxy')
    @surveys_proxy.stub!(:find).and_return(@survey)
    
    @invitation = mock_model(SurveyInvitation, :id => 1, :inviter => @current_organization, :to_xml => 'XML', :save! => true)
    @invitation.stub!(:survey_id).and_return(@survey.id)
    @invitations_proxy.stub!(:find).and_return(@invitation)
    
    @organization_1 = mock_model(Organization, :survey_invitations => [mock_model(SurveyInvitation, :survey_id => @survey.id)])
    @organizations = [@current_organization,@organization_1]
    
    @network = mock_model(Network, :id => '1', :name => "test")  
    @network.stub!(:organizations).and_return(@organizations)  
    @networks_proxy = mock('networks proxy')
    @networks_proxy.stub!(:find).and_return(@network)
    
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    @current_organization.stub!(:survey_invitations).and_return([])
    @current_organization.stub!(:networks).and_return(@networks_proxy)
    Organization.stub!(:find_by_email).and_return(@current_organization)
    
    @surveys_proxy.stub!(:running).and_return(@surveys_proxy)
    @invitations_proxy.stub!(:new).and_return(@invitation)
    
    @params = {:survey_id => 1, :invitation => {:network_id => '1'}}
  end
 
  def do_get
    post :create_with_network, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should find all members of the network" do
    @network.should_receive(:organizations).and_return(@organizations)
    do_get
  end
   
  it "should create a new survey_invitation if the invitee has not already been invited" do
    @invitations_proxy.should_receive(:new).with(:invitee => @current_organization, :inviter => @current_organization).and_return(@invitation)
    do_get
  end
     
  it "should require the organization is the sponsor of the survey" do
    @current_organization.should_receive(:sponsored_surveys).and_return(@surveys_proxy)
    do_get
  end
   
  it "should redirect to the invitation index page and flash a message regarding the success of the action" do
    do_get
    flash[:message].should eql("Invitation sent to all members of #{@network.name}.")
    response.should redirect_to('surveys/1/invitations')
  end
   
end


describe SurveyInvitationsController, " handling POST /surveys/1/invitations with external invitation" do

 before do
    @current_organization = mock_model(Organization, :name => "test")
    login_as(@current_organization)
    
    @invitation = mock_model(ExternalSurveyInvitation, :id => 1, :inviter => @current_organization, :to_xml => 'XML', :save => true, :inviter= => @current_organization)
    @invitations_proxy = mock('invitations proxy')
    @invitations_proxy.stub!(:find).and_return(@invitation)
    
    @external_invitations_proxy = mock('external invitations proxy')
    @external_invitations_proxy.stub!(:new).and_return(@invitation)
    
    @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => @current_organization, :job_title => "test", :invitations => @invitations_proxy)
    @surveys_proxy = mock('surveys proxy')
    @surveys_proxy.stub!(:find).and_return(@survey)
    
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    @current_organization.stub!(:survey_invitations).and_return([])
    Organization.stub!(:find_by_email).and_return(nil)
    
    @surveys_proxy.stub!(:running).and_return(@surveys_proxy)
    @invitations_proxy.stub!(:new).and_return(@invitation)
    @survey.stub!(:external_invitations).and_return(@external_invitations_proxy)
        
    @params = {:survey_id => 1, :invitation => {:email => "test", :name => "test"}}
  end
 
  def do_post
    post :create, @params
  end
   
  it "should create a new external_survey_invitation if the invitee does not exist" do
    @external_invitations_proxy.should_receive(:new).and_return(@invitation)
    do_post
  end
   
  it "should redirect to the invitation index page and flash a message regarding the success of the action" do
    do_post
    flash[:message].should eql("Invitation sent to external email address #{@params[:invitation][:email]}.")
    response.should redirect_to('surveys/1/invitations')
  end
   
end

describe SurveyInvitationsController, " handling DELETE /surveys/1/invitations/1" do

 before do
    @current_organization = mock_model(Organization, :name => "test")
    login_as(@current_organization)
    
    @invitation = mock_model(SurveyInvitation, :id => 1, :inviter => @current_organization, :to_xml => 'XML', :destroy => true)
    @invitations_proxy = mock('invitations proxy')
    @invitations_proxy.stub!(:find).and_return(@invitation)
    
    @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => @current_organization, :job_title => "test", :invitations => @invitations_proxy)
    @surveys_proxy = mock('surveys proxy')
    @surveys_proxy.stub!(:find).and_return(@survey)
    
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    @current_organization.stub!(:survey_invitations).and_return([])
    Organization.stub!(:find_by_email).and_return(@current_organization)
    
    @surveys_proxy.stub!(:running).and_return(@surveys_proxy)
    @invitations_proxy.stub!(:new).and_return(@invitation)
    
    @params = {:survey_id => 1, :id => @invitation.id}
  end
 
  def do_delete
    delete :destroy, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_delete
  end
  
  it "should only allow the sponsor to delete invitations" do
    @current_organization.should_receive(:sponsored_surveys).and_return(@surveys_proxy)
    do_delete
  end
   
  it "should find the invitation requested" do
    @invitations_proxy.should_receive(:find).and_return(@invitation)
    do_delete
  end
   
  it "should destroy the invitation requested" do
    @invitation.should_receive(:destroy).and_return(true)
    do_delete
  end
   
  it "should redirect to the invitation index page" do
    do_delete
    response.should redirect_to('/surveys/1/invitations')
  end
   
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
    
    @network = mock_model(Network, :invitations => @invitations_proxy, :external_invitations => @invitations_proxy, :name => 'network')
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
   
  it "should find the external network invitations" do
    @network.should_receive(:external_invitations).and_return(@invitations_proxy)
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
    
    @invitation = mock_model(Invitation, :to_xml => 'XML')
    @invitations = [@invitation]
    @invitations.stub!(:to_xml).and_return('XML')
    @invitations_proxy = mock('Invitations Proxy', :find => @invitations)
    
    @network = mock_model(Network, :invitations => @invitations_proxy, :external_invitations => @invitations_proxy, :name => 'network')
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
    @invitation.should_receive(:to_xml).at_least(:once).and_return("XML")
    do_get
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
    
    @invited_organization = mock_model(Organization, :name => 'Invited Org', :network_invitations => [])
    Organization.stub!(:find_by_email).and_return(@invited_organization)
    
    @invitations_proxy = mock('invitations proxy', :new => @invitation)
    @external_invitations_proxy = mock('external_invitations_proxy', :new => @invitation)
    
    @network = mock_model(Network, :invitations => @invitations_proxy, :external_invitations => @external_invitations_proxy)
    @network_proxy = mock('Network Proxy', :find => @network)
    
    @invitation = mock_model(Invitation, :save => true, :network_id => @network.id, :inviter= => @organization)
    
    @organization.stub!(:owned_networks).and_return(@network_proxy)

    @params = {:network_id => 1, :invitation => {}}
  end
  
  def do_post
    post :create, @params
  end
  
  it "should create a new network invitation if the invitee exists" do
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
  
  it "should not create a new network invitation if the invitee exists and already is invited" do
    @invited_organization.should_receive(:network_invitations).and_return([@invitation])
    @invitations_proxy.should_not_receive(:new)
    
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
