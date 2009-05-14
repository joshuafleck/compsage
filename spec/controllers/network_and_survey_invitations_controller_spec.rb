require File.dirname(__FILE__) + '/../spec_helper'

#specs specific to SurveyInvitationsController
describe SurveyInvitationsController, " #route for" do
  it "should map { :controller => 'invitations', :action => 'index', :survey_id => '1' } to /surveys/1/invitations" do
    route_for(:controller => "survey_invitations", :action => "index", :survey_id => '1').should == "/surveys/1/invitations"
  end

  it "should map { :controller => 'invitations', :action => 'new', :survey_id => '1' } to /surveys/1/invitations/new" do
    route_for(:controller => "survey_invitations", :action => "new", :survey_id => '1').should == "/surveys/1/invitations/new"
  end

  it "should map { :controller => 'invitations', :action => 'destroy', :id => '1', :survey_id => '1'} to /surveys/1/invitations/1" do
    route_for(:controller => "survey_invitations", :action => "destroy", :id => '1', :survey_id => '1').should == { :path => "/surveys/1/invitations/1", :method => :delete }
  end
  
  it "should map { :controller => 'invitations', :action => 'decline', :id => '1', :survey_id => '1'} to /surveys/1/invitations/1/decline" do
    route_for(:controller => "survey_invitations", :action => "decline", :id => '1', :survey_id => '1').should == { :path => "/surveys/1/invitations/1/decline", :method => :put }
  end    

  it "should map { :controller => 'invitations', :action => 'create_for_network', :survey_id => '1'} to /surveys/1/invitations/create_for_network" do
    route_for(:controller => "survey_invitations", :action => "create_for_network", :survey_id => '1').should == { :path => "/surveys/1/invitations/create_for_network", :method => :post }
  end 
end

describe SurveyInvitationsController, " handling GET /surveys/1/invitations" do

  before do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @invitation = mock_model(SurveyInvitation, :id => 1, :inviter => @current_organization)
    @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => @current_organization, :job_title => "test", :all_invitations => @invitations)
    @surveys_proxy = mock('surveys proxy')
    @surveys_proxy.stub!(:find).and_return(@survey)
    @network = mock_model(Network, :id => "1", :included= => "1")
    @networks = [@network]
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    @current_organization.stub!(:networks).and_return(@networks)
    
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
    assigns(:invitations).should eql(@invitations)
  end
   
  it "should assign the networks for the view" do    
    do_get
    assigns(:networks).should eql(@networks)
  end   
   
  it "should find all invitations" do
    @survey.should_receive(:all_invitations).and_return(@invitations)
    do_get
  end
  
  it "should find all networks" do
    @current_organization.should_receive(:networks).and_return(@networks)
    do_get
  end  
      
  it "should error if requesting organization is not survey sponsor" do
    @current_organization.should_receive(:sponsored_surveys).and_return(@surveys_proxy)
    do_get
  end
   
end

describe SurveyInvitationsController, " handling POST /surveys/1/invitations" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    @survey = Factory(:survey, :sponsor => @current_organization)
    @current_organization.sponsored_surveys.stub(:find).and_return(@survey)

    @params = {:survey_id => @survey.id, :organization_id => @current_organization.id}
  end
 
  def do_post
    post :create, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post
  end
   
  describe "when inviting an organization by id" do
    before do
      @other_organization = Factory(:organization)
      @params.merge!({:organization_id => @other_organization.id.to_s})
    end

    it "should find the organization to invite" do
      Organization.should_receive(:find).at_least(:once).and_return(@other_organization)
      do_post
    end

    it "should create an internal invitation to the survey" do
      @survey.invitations.should_receive(:new).and_return(Invitation.new)
      do_post
    end
  end
end

describe SurveyInvitationsController, " handling DELETE /surveys/1/invitations/1" do
  before do
    @current_organization = mock_model(Organization, :name => "test")
    login_as(@current_organization)
    
    @invitation = mock_model(SurveyInvitation, :id => 1, :inviter => @current_organization, :to_xml => 'XML', :destroy => true)
    @invitations_proxy = mock('invitations proxy')
    @invitations_proxy.stub!(:find).and_return(@invitation)
    
    @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => @current_organization, :job_title => "test", :internal_and_external_invitations => @invitations_proxy)
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

describe SurveyInvitationsController,  "handling PUT /surveys/1/invitations/1/decline" do
  before do
    @survey = Factory.create(:survey)    
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @invitation = mock_model(
      SurveyInvitation, 
      :survey => @survey, 
      :inviter => @survey.sponsor, 
      :invitee => @current_organization, 
      :id => "1",
      :decline! => true)
      
    @survey_invitations_proxy = mock('surveys proxy', :find => @invitation)
    
    @current_organization.stub!(:survey_invitations).and_return(@survey_invitations_proxy)
    
    @params = {:survey_id => @survey.id, :id => @invitation.id}
  end
  
  def do_put
    put :decline, @params
  end
  
  it "should be successful" do
        do_put
        response.should redirect_to(surveys_path)
  end  
  
  it "should change the status of the invitation to 'declined'" do
    @invitation.should_receive(:decline!)
    do_put
  end
  
end

  
#specs specific to NetworkInvitationsController  
describe NetworkInvitationsController, " #route for" do
    it "should map { :controller => 'invitations', :action => 'index', :network_id => '1' } to /networks/1/invitations" do
      route_for(:controller => "network_invitations", :action => "index", :network_id => '1').should == "/networks/1/invitations"
    end

    it "should map { :controller => 'invitations', :action => 'new', :network_id => '1' } to /networks/1/invitations/new" do
      route_for(:controller => "network_invitations", :action => "new", :network_id => '1').should == "/networks/1/invitations/new"
    end

    it "should map { :controller => 'invitations', :action => 'destroy', :id => '1', :network_id => '1'} to /networks/1/invitations/1" do
      route_for(:controller => "network_invitations", :action => "destroy", :id => '1', :network_id => '1').should == {:path => "/networks/1/invitations/1", :method => :delete }
    end    
    
    it "should map { :controller => 'invitations', :action => 'decline', :id => '1', :network_id => '1'} to /networks/1/invitations/1/decline" do
      route_for(:controller => "network_invitations", :action => "decline", :id => '1', :network_id => '1').should == { :path => "/networks/1/invitations/1/decline", :method => :put }
    end
end

describe NetworkInvitationsController, " handling GET /networks/1/invitations" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @invitation = mock_model(Invitation)
    @invitations = [@invitation]
    @invalid_invitations = []
    
    @network = mock_model(Network, :all_invitations => @invitations, :name => 'network')
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
        @network.should_receive(:all_invitations).and_return(@invitations)
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
     
  it "should assign the invalid invitations the view" do    
    do_get
    assigns(:invalid_invitations).should eql(@invalid_invitations)
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
    
    @network = mock_model(Network, :all_invitations => @invitations, :name => 'network')
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
    @invitations.should_receive(:to_xml).at_least(:once).and_return("XML")
    do_get
  end
  
end

describe NetworkInvitationsController, " handling POST /networks/1/invitations" do

 before do
    @current_organization = mock_model(Organization, :id => "1")
    login_as(@current_organization)
    
    @network = mock_model(Network, :owner => @current_organization, :id => "1")
       
    @organization1 = mock_model(Organization, :id => "2", :networks => [])
    @organization2 = mock_model(Organization, :id => "3", :networks => [])
    @organization3 = mock_model(Organization, :id => "4", :networks => [])
    
    @owned_networks_proxy = mock('owned_networks_proxy', :find => @network)
    @invitations_proxy = mock('invitations_proxy')
    
    @current_organization.stub!(:owned_networks).and_return(@owned_networks_proxy)
    
    Organization.stub!(:find_by_id).with(@organization1.id).and_return(@organization1)
    Organization.stub!(:find_by_id).with(@organization2.id).and_return(@organization2)
    Organization.stub!(:find_by_id).with(@organization3.id).and_return(@organization3)
    @organization1.stub!(:invited_networks).and_return(@invited_networks_proxy_excl)
    @organization2.stub!(:invited_networks).and_return(@invited_networks_proxy_incl)
    @organization3.stub!(:invited_networks).and_return(@invited_networks_proxy_incl)
    @network.stub!(:all_invitations).and_return(@invitations_proxy)
    
    Invitation.stub!(:create_internal_or_external_invitations).and_return([[],@invitations_proxy])
    
    @params = {
          :network_id => @network.id.to_s, 
          :invite_organization => { 
            @organization1.id.to_s => {:included => '1'}, 
            @organization2.id.to_s => {:included => '1'}, 
            @organization3.id.to_s => {}
          },
          :external_invite => {
            '1' => {"included" => '1', "organization_name" => 'ext1', "email" => 'ext1@ext1.com'}
          }
        }
        
  end
 
  def do_post
    post :create, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post
  end
  
  it "should find all of the invited organizations" do
    Organization.should_receive(:find_by_id).with(@organization1.id).and_return(@organization1)
    Organization.should_receive(:find_by_id).with(@organization2.id).and_return(@organization2)
    do_post
  end
    
  it "should not create invitations for unselected organizations" do
    Organization.should_not_receive(:find_by_id).with(@organization3.id)
    do_post
  end  
  
  it "should build the invitations" do
    Invitation.should_receive(:create_internal_or_external_invitations).with([@params[:external_invite]["1"]],[@organization1,@organization2],[],@current_organization,@network)
    do_post
  end
   
  it "should assign the invitations to the view" do
    @network.should_receive(:all_invitations)
    do_post
        assigns[:invitations].should_not be_nil
  end
  
  it "should assign the invalid invitations the view" do    
    do_post
    assigns(:invalid_invitations).should eql(@invitations_proxy)
   end   
   
  it "should flash a message notiing if invitations were sent" do
    do_post
    flash[:notice].should eql("No invitations were sent")
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
  
describe NetworkInvitationsController, " handling PUT /network/1/invitations/1/decline" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @invitation = mock_model(NetworkInvitation, :destroy => true)
    @invitations_proxy = mock('invitations proxy', :find => @invitation)

    @organization.stub!(:network_invitations).and_return(@invitations_proxy)
    
    @params = {:network_id => 1, :id => 1}
  end
  
  def do_put
    put :decline, @params
  end
  
  it "should find the invitation requested" do
    @invitations_proxy.should_receive(:find).and_return(@invitation)
        do_put
  end
  
  it "should destroy the invitation requested" do
        @invitation.should_receive(:destroy)
        do_put
  end
  
  it "should redirect to the network index page" do
        do_put
        response.should redirect_to(networks_path())
  end  
end
