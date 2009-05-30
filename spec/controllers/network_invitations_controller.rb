require File.dirname(__FILE__) + '/../spec_helper'

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
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    @network = Factory(:network, :owner => @current_organization)
    @current_organization.owned_networks.stub(:find).and_return(@network)

    @params = {:network_id => @network.id, :organization_id => @current_organization.id}
  end
 
  def do_post
    post :create, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post
  end
 
  describe "when inviting by organization id" do
    before do
      @other_organization = Factory(:organization)
      Organization.stub!(:find).and_return(@other_organization)
      @params.merge!({:organization_id => @other_organization.id.to_s})
    end

    it "should find the organization to invite" do
      Organization.should_receive(:find).at_least(:once).and_return(@other_organization)
      do_post
    end

    it "should create an internal invitation to the network" do
      @network.invitations.should_receive(:new).and_return(Invitation.new(:invitee => @other_organization))
      do_post
    end
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
