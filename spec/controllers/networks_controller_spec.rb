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
    @organization.stub!(:networks).and_return([@network])
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
  
  it "should assign the found networks for the view" do
    do_get
    assigns[:networks].should == [@network]
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
    
    @network = mock_model(Network, :to_xml => "XML")
    
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
    
    @network = mock_model(Network, :to_xml => "XML")
    
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
end

describe NetworksController, " handling GET /networks/1/edit" do
  
  before do
    @organization = mock_model(Organization)
    login_as(@organization)
    
    @network = mock_model(Network, :to_xml => "XML")
    
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
    
    @network = mock_model(Network, :save! => true)
    
    @owned_networks_proxy = mock('owned networks proxy', :new => @network)
    @networks_proxy = mock('networks proxy', :<< => true)
    @organization.stub!(:networks).and_return(@networks_proxy)
    @organization.stub!(:owned_networks).and_return(@owned_networks_proxy)
  end
  
  def do_post
    post :create
  end
  
  it "should create a new network" do
    @owned_networks_proxy.should_receive(:new).and_return(@network)
    do_post
  end
  
  it "should make the owner a member of the network" do
    @networks_proxy.should_receive(:<<)
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
    
    @network = mock_model(Network, :update_attributes! => true)
    
    @owned_networks_proxy = mock('owned networks proxy', :find => @network)
    
    @organization.stub!(:owned_networks).and_return(@owned_networks_proxy)
    
    @params = {:id => @network.id}
  end
  
  def do_put
    put :update, @params
  end
  
  it "should find the network requested" do
    @owned_networks_proxy.should_receive(:find).and_return(@network)
    do_put
  end
  
  it "should update the selected network" do
    @network.should_receive(:update_attributes!)
    do_put
  end

  it "should redirect to the network show page" do
    do_put
    response.should redirect_to(network_path(@network))
  end
  
  it "should flash a message regarding the success of the edit" do
    do_put
    flash[:notice].should == "Your network was updated successfully."
  end

end

describe NetworksController, " handling PUT /networks/1/leave" do

  it "should find the network requested" do
    pending    
  end
  
  it "should allow the organization to leave the network" do
    pending    
  end

  it "should return a response regarding the success of the action when the request is XML" do
    pending
  end

  it "should redirect to the network index" do
    pending    
  end
  
  it "should flash a message regarding the success of the action" do
    pending    
  end

end

#We cannot allow the owner to leave the network without changing the owner
#If the owner leaves the network, the network will no longer show up in that owner's index page
describe NetworksController, "handling PUT /networks/1/leave when the organization is the owner of the network" do

  it "should return an error when the request is XML" do
    pending
  end

  it "should redirect to the network edit page" do
    pending
  end
  
  it "should flash a message instructing the organization to change the owner of the network" do
    pending
  end

end

describe NetworksController, " handling PUT /networks/1/join" do
  
  it "should require an invitation"
  
  it "should add the organization to the network" do
    pending
  end

  it "should destroy the invitation when an invitation exists" do
    pending
  end

  it "should return a response regarding the success of the action when the request is XML" do
    pending
  end
  
  it "should redirect to the network show page" do
    pending    
  end

  it "should flash a message regarding the success of the action" do
    pending    
  end  
end

describe NetworksController, " handling DELETE /networks/1" do

  it "should find the network requested" do
    pending    
  end
  
  it "should destroy the network" do
    pending    
  end
 
  it "should return a response regarding the success of the action when the request is XML" do
    pending
  end
   
  it "should redirect to the network index" do
    pending    
  end
  
  it "should flash a message regarding the success of the delete" do
    pending
  end

end
