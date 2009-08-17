require File.dirname(__FILE__) + '/../spec_helper'

describe NetworksController, "#route_for" do
  it "should map { :controller => 'networks', :action => 'index' } to /networks" do
    route_for(:controller => "networks", :action => "index").should == "/networks"
  end

  it "should map { :controller => 'networks', :action => 'new' } to /networks/new" do
    route_for(:controller => "networks", :action => "new").should == "/networks/new"
  end

  it "should map { :controller => 'networks', :action => 'show', :id => '1' } to /networks/1" do
    route_for(:controller => "networks", :action => "show", :id => '1').should == "/networks/1"
  end

  it "should map { :controller => 'networks', :action => 'edit', :id => '1' } to /networks/1/edit" do
    route_for(:controller => "networks", :action => "edit", :id => '1').should == "/networks/1/edit"
  end

  it "should map { :controller => 'networks', :action => 'update', :id => '1'} to /networks/1" do
    route_for(:controller => "networks", :action => "update", :id => '1').should == { :path => "/networks/1", :method => :put }
  end

  it "should map { :controller => 'networks', :action => 'destroy', :id => '1'} to /networks/1" do
    route_for(:controller => "networks", :action => "destroy", :id => '1').should == { :path => "/networks/1", :method => :delete }
  end
  
  it "should map { :controller => 'networks', :action => 'leave', :id => '1'} to /networks/1/leave" do
    route_for(:controller => "networks", :action => "leave", :id => '1').should == { :path => "/networks/1/leave", :method => :put }
  end

  it "should map { :controller => 'networks', :action => 'join', :id => '1'} to /networks/1/join" do
    route_for(:controller => "networks", :action => "join", :id => '1').should == { :path => "/networks/1/join", :method => :put }
  end
end

describe NetworksController, " handling GET /networks" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @network = Factory(:network, :owner => @current_organization)
    @invitation = Factory(:network_invitation, :invitee => @current_organization)
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
  
  it "should assign the found networks and invitations for the view" do
    do_get
    assigns[:networks].should == [@network]
    assigns[:network_invitations].should == [@invitation]
  end
  
end

describe NetworksController, " handling GET /networks/1" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @network = Factory(:network, :owner => @current_organization)

    @network_member = Factory(:organization)
    @network.organizations << @network_member

    @params = {:id => @network.id}
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

  it "should render the show template" do
    do_get
    response.should render_template("show")    
  end
  
  it "should assign the network to the view" do
    do_get
    assigns[:network].should == @network    
  end

  it "should assign the network's members to the view, minus the current organization" do
    do_get
    assigns[:members].should include(@network_member)
    assigns[:members].should_not include(@organization)
  end
end

describe NetworksController, " handling GET /networks/new" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
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
  
  it "should assign a network to the view" do
    do_get
    assigns[:network].should_not be_nil
  end
end

describe NetworksController, " handling GET /networks/1/edit" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @network = Factory(:network, :owner => @current_organization)
    @params = {:id => @network.id}
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
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    @network = Factory(:network, :owner => @current_organization)
    @params = {:network => @network.attributes}
  end
  
  def do_post
    post :create, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post
  end
  
  it "should redirect to the show network view" do
    do_post
    response.should redirect_to(network_path(@network.id + 1))
  end
  
  it "should create a new network" do
    lambda { do_post }.should change(Network, :count).by(1)
  end
end

describe NetworksController, " handling PUT /networks/1" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @network = Factory(:network, :owner => @current_organization)   
    @params = {:id => @network.id, :network => {:name => 'Updated!'}}
  end
  
  def do_put
    put :update, @params
    @network.reload
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_put
  end
  
  it "should update the selected network" do
    do_put
    @network.name.should == 'Updated!'
  end

  it "should redirect to the network show page" do
    do_put
    response.should redirect_to(network_path(@network))
  end
  
end

describe NetworksController, " handling PUT /networks/1/leave" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    @network = Factory(:network, :owner => @current_organization)
    
    @params = {:id => @network.id}
  end
  
  def do_put
    put :leave, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_put
  end
  
  it "should allow the organization to leave the network" do
    lambda { do_put }.should change(Network, :count).by(-1)
  end

  it "should redirect to the network index" do
    do_put
    response.should redirect_to(networks_path)
  end
  
end

describe NetworksController, " handling PUT /networks/1/join" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    @network = Factory(:network, :owner => Factory(:organization))
    @invite = Factory(:network_invitation, :network => @network, :invitee => @current_organization)

    @params = {:id => @network.id}
  end
  
  def do_put
    put :join, @params
  end
  
  it "should accept the invitation" do
    lambda { do_put }.should change(@current_organization.networks, :count).by(1)
  end
  
  it "should destroy the invitaiton" do
    lambda { do_put }.should change(NetworkInvitation, :count).by(-1)
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
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    @network = Factory(:network, :owner => Factory(:organization))
    
    @params = {:id => @network.id}
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
    flash[:notice].should == "You must get an invite before joining that network."
  end
end

describe NetworksController, "handling PUT /networks/1/evict" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @network = Factory(:network, :owner => @current_organization)
    @network_member = Factory(:organization)
    @network.organizations << @network_member
    
    @params = {:id => @network.id, :organization_id => @network_member.id}
  end
  
  def do_put
    put :evict, @params
  end
  
  it "should remove the organization from the network" do
    lambda { do_put }.should change(@network.organizations, :count).by(-1)
  end
  
  it "should redirect to the network show page" do
    do_put
    response.should redirect_to(network_path(@network))
  end
  
  describe "when the organization being evicted is the current organization" do
    it " should not remove the organization from the network" do
      @params = {:id => @network.id, :organization_id => @current_organization.id}
      lambda { do_put }.should_not change(@network.organizations, :count).by(-1)
    end
  end
  
end