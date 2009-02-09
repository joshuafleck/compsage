require File.dirname(__FILE__) + '/../spec_helper'

describe NetworksController, "#route_for" do
  it "should map { :controller => 'networks', :action => 'index' } to /networks" do
    route_for(:controller => "networks", :action => "index").should == "/networks"
  end

  it "should map { :controller => 'networks', :action => 'new' } to /networks/new" do
    route_for(:controller => "networks", :action => "new").should == "/networks/new"
  end

  it "should map { :controller => 'networks', :action => 'show', :id => 1 } to /networks/1" do
    route_for(:controller => "networks", :action => "show", :id => 1).should == "/networks/1"
  end

  it "should map { :controller => 'networks', :action => 'edit', :id => 1 } to /networks/1/edit" do
    route_for(:controller => "networks", :action => "edit", :id => 1).should == "/networks/1/edit"
  end

  it "should map { :controller => 'networks', :action => 'update', :id => 1} to /networks/1" do
    route_for(:controller => "networks", :action => "update", :id => 1).should == "/networks/1"
  end

  it "should map { :controller => 'networks', :action => 'destroy', :id => 1} to /networks/1" do
    route_for(:controller => "networks", :action => "destroy", :id => 1).should == "/networks/1" 
  end
  
  it "should map { :controller => 'networks', :action => 'leave', :id => 1} to /networks/1/leave" do
    route_for(:controller => "networks", :action => "leave", :id => 1).should == "/networks/1/leave"  
  end

  it "should map { :controller => 'networks', :action => 'join', :id => 1} to /networks/1/join" do
    route_for(:controller => "networks", :action => "join", :id => 1).should == "/networks/1/join"
  end
end

describe NetworksController, " handling GET /networks" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @network = mock_model(Network)
    @invitation = mock_model(NetworkInvitation)    
    @organization.stub!(:networks).and_return([@network])
    @organization.stub!(:network_invitations).and_return([@invitation])
  end
  
  def do_get
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success 
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should show the index template" do
    do_get
    response.should render_template('index')
  end
  
  it "should find all networks the organization belongs to" do
    @organization.should_receive(:networks).and_return([@network])
    do_get
  end
  
  it "should find all network invitations for the organization" do
    @organization.should_receive(:network_invitations).and_return([@invitation])
    do_get
  end  
  
  it "should assign the found networks and invitations for the view" do
    do_get
    assigns[:networks].should == [@network]
    assigns[:network_invitations].should == [@invitation]
  end
  
  it "should support sorting..." do
    pending
  end
    
  it "should support pagination..." do
    pending
  end
  
end

describe NetworksController, " handling GET /networks.xml" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @network = mock_model(Network, :to_xml => "XML")
    @networks = [@network]
    @organization.stub!(:networks).and_return(@networks)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find all networks the organization belongs to" do
    @organization.should_receive(:networks).and_return([@network])
    do_get
  end
  
  it "should render the found networks as XML" do
    @networks.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
end

describe NetworksController, " handling GET /networks/1" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @organizations_proxy = mock('org_proxy', :find => [])
    @network = mock_model(Network, :name => "Network!", :organizations => @organizations_proxy)
    @network_proxy = mock('Network Proxy', :find => @network)
    @organization.stub!(:networks).and_return(@network_proxy)
    
    @params = {:id => "1"}
  end
  
  def do_get
    get :show, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find the network requested" do
    @network_proxy.should_receive(:find).and_return(@network)
    do_get    
  end  

  it "should find the network members" do
    @network.should_receive(:organizations).and_return(@organizations_proxy)
    do_get
  end

  it "should render the show template" do
    do_get
    response.should render_template("show")    
  end
  
  it "should assign the found network to the view" do
    do_get
    assigns[:network].should == @network    
  end  
end

describe NetworksController, " handling GET /networks/1.xml" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @organizations_proxy = mock('org_proxy', :find => [])
    @network = mock_model(Network, :name => "Network!", :organizations => @organizations_proxy, :to_xml => "XML")
    
    @network_proxy = mock('Network Proxy', :find => @network)
    @organization.stub!(:networks).and_return(@network_proxy)
    
    @params = {:id => "1"}
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :show, @params
  end
  
  it "should be successful" do
    do_get
    response.should be_success    
  end
   
  it "should find the network requested" do
    @network_proxy.should_receive(:find).and_return(@network)
    do_get
  end
  
  it "should render the found network and network members as XML" do
    @network.should_receive(:to_xml, :with => {:include => :organizations}).and_return("XML")
    do_get
    response.body.should == "XML"
  end
end

describe NetworksController, " handling GET /networks/new" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @network = mock_model(Network)
    Network.stub!(:new).and_return(@network)
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
  
  it "should create a new network" do
    Network.should_receive(:new).and_return(@network)
    do_get
  end
  
  it "should assign a new network to the view" do
    do_get
    assigns[:network].should == @network
  end
  
  it "should not save the network" do
    @network.should_not_receive(:save)
    do_get
  end
  
end

describe NetworksController, " handling GET /networks/1/edit" do
  
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @network = mock_model(Network, :to_xml => "XML", :name => "Network")
    
    @network_proxy = mock('Network Proxy', :find => @network)
    @organization.stub!(:owned_networks).and_return(@network_proxy)
    
    @params = {:id => "1"}
  end
  
  def do_get
    get :edit, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the network requested" do
    @network_proxy.should_receive(:find).and_return(@network)
    do_get
  end
  
  it "should render the edit template" do
    do_get
    response.should render_template('edit')    
  end
  
  it "should assign the found network to the view" do
    do_get
    assigns[:network].should == @network    
  end

end

describe NetworksController, " handling POST /networks" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @network = mock_model(Network, :save => true)
    
    @owned_networks_proxy = mock('owned networks proxy', :new => @network)
    @networks_proxy = mock('networks proxy')
    @organization.stub!(:networks).and_return(@networks_proxy)
    @organization.stub!(:owned_networks).and_return(@owned_networks_proxy)
  end
  
  def do_post
    post :create
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post
  end
  
  it "should create a new network" do
    @owned_networks_proxy.should_receive(:new).and_return(@network)
    @network.should_receive(:save)
    do_post
  end
  
  it "should redirect to the show invitation view" do
    do_post
    response.should redirect_to(network_invitations_path(@network.id))
  end
end

describe NetworksController, " handling PUT /networks/1" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @network = mock_model(Network, :attributes= => true, :save => true)
    
    @owned_networks_proxy = mock('owned networks proxy', :find => @network)
    
    @organization.stub!(:owned_networks).and_return(@owned_networks_proxy)
    
    @params = {:id => @network.id}
  end
  
  def do_put
    put :update, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_put
  end
  
  it "should find the network requested" do
    @owned_networks_proxy.should_receive(:find).and_return(@network)
    do_put
  end
  
  it "should update the selected network" do
    @network.should_receive(:attributes=)
    do_put
  end

  it "should redirect to the network show page" do
    do_put
    response.should redirect_to(network_path(@network))
  end
  
end

describe NetworksController, " handling PUT /networks/1/leave" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @network = mock_model(Network, :update_attributes! => true, :owner => mock_model(Organization))
    
    @networks_proxy = mock('networks proxy', :find => @network, :delete => true)
    
    @organization.stub!(:networks).and_return(@networks_proxy)
    
    @params = {:id => @network.id}
  end
  
  def do_put
    put :leave, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_put
  end
  
  it "should find the network requested" do
    @networks_proxy.should_receive(:find).and_return(@network)
    do_put
  end
  
  it "should allow the organization to leave the network" do
    @networks_proxy.should_receive(:delete).with(@network)
    do_put
  end

  it "should redirect to the network index" do
    do_put
    response.should redirect_to(networks_path)
  end
  
  it "should flash a message regarding the success of the action" do
    do_put
    flash[:notice].should == "You have successfully left the network."
  end

end

describe NetworksController, " handling PUT /networks/1/join" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @network = mock_model(Network, :owner => @organization)
    @invite = mock_model(NetworkInvitation, :network => @network, :invitee => @organization, :accept! => true)
    
    @invites_proxy = mock('invites proxy', :find_by_network_id => @invite)
    
    @organization.stub!(:network_invitations).and_return(@invites_proxy)
    @organization.stub!(:networks).and_return(@networks_proxy)
    
    @params = {:id => @network.id}
  end
  
  def do_put
    put :join, @params
  end
  
  it "should accept the invitation" do
    @invite.should_receive(:accept!)
    do_put
  end
  
  it "should redirect to the network show page" do
    do_put
    response.should redirect_to(network_path(@network))
  end

  it "should flash a message regarding the success of the action" do
    do_put
    flash[:notice].should == "You have joined the network!"
  end
end

describe NetworksController, "handling PUT /networks/1/join with no invitation" do
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @invites_proxy = mock('invites proxy', :find_by_network_id => nil)
    
    @organization.stub!(:network_invitations).and_return(@invites_proxy)
    
    @params = {:id => 1}
  end
  
  def do_put
    put :join, @params
  end
  
  it "should redirect to networks index" do
    do_put
    response.should redirect_to(networks_path)
  end
  
  it "should flash an error message" do
    do_put
    flash[:error].should == "You get an invite before joining that network."
  end
end
