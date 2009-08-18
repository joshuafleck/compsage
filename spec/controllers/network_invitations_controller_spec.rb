require File.dirname(__FILE__) + '/../spec_helper'

describe NetworkInvitationsController, " #route for" do
    it "should map { :controller => 'invitations', :action => 'create', :network_id => '1' } to /networks/1/invitations" do
      route_for(:controller => "network_invitations", :action => "create", :network_id => '1').should == { :path => "/networks/1/invitations", :method => :post }
    end

    it "should map { :controller => 'invitations', :action => 'decline', :id => '1', :network_id => '1'} to /networks/1/invitations/1/decline" do
      route_for(:controller => "network_invitations", :action => "decline", :id => '1', :network_id => '1').should == { :path => "/networks/1/invitations/1/decline", :method => :put }
    end
end

describe NetworkInvitationsController, " handling POST /networks/1/invitations" do

  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @network = Factory(:network, :owner => @current_organization)
    @other_organization = Factory(:organization)
    @member = Factory(:organization)
    
    @network.organizations << @member

    @params = {:network_id => @network.id, :organization_id => @other_organization.id}
  end
 
  def do_post
    post :create, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post
  end
 
  it "should create an internal invitation to the survey" do
    lambda{ do_post }.should change(@other_organization.network_invitations,:count).by(1)
  end
  
  describe "when inviting an organization by email" do
    before do
      @params.merge!(:external_invitation => {:organization_name => "josh inc", :email => "flec0026@umn.edu"})
      @params.delete(:organization_id)
    end

    it "should create an external invitation to the survey" do
      lambda{ do_post }.should change(@network.external_invitations,:count).by(1)
    end
  end  
  
  it "should flash a notice" do
    do_post
    flash[:notice].should_not be_blank
  end
  
  it "should assign the network to the view" do
    do_post
    assigns(:network).should == @network
  end  
  
  it "should assign the invitation to the view" do
    do_post
    assigns(:invitation).should_not be_blank
  end  
    
  it "should redirect to the created network" do
    do_post
    response.should redirect_to(network_path(@network))
  end  
  
  describe "with invalid invitation" do
    before do
      @params[:organization_id] = @current_organization.id
    end    
      
    it "should assign the network members to the view" do
      do_post
      assigns(:members).should_not be_blank
    end  

    it "should render the network show page" do
      do_post
      response.should render_template('/networks/show')
    end    
  end
end
  
describe NetworkInvitationsController, " handling PUT /network/1/invitations/1/decline" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @network = Factory(:network)
    @invitation = Factory(:network_invitation, :invitee => @current_organization, :network => @network)
    
    @params = {:network_id => @network.id, :id => @invitation.id}
  end
  
  def do_put
    put :decline, @params
  end
  
  it "should destroy the invitation requested" do
    lambda{ do_put }.should change(@network.invitations,:count).by(-1)
  end
  
  it "should redirect to the network index page" do
    do_put
    response.should redirect_to(networks_path())
  end  
end
