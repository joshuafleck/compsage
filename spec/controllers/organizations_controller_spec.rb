require File.dirname(__FILE__) + '/../spec_helper'

describe OrganizationsController, "#route_for" do

  it "should map { :controller => 'organizations', :action => 'show', :id => '1' } to /organizations/1" do
    route_for(:controller => "organizations", :action => "show", :id => '1').should == "/organizations/1"
  end
  
  it "should map { :controller => 'organizations', :action => 'search'} to /organizations/search" do
    route_for(:controller => "organizations", :action => "search").should == "/organizations/search"
  end
  
  it "should map { :controller => 'organizations', :action => 'invite_to_survey', :id => '1' } to /organizations/1/invite_to_survey" do
    route_for(
      :controller => "organizations", 
      :action     => "invite_to_survey", 
      :id         => '1').should == { :path => "/organizations/1/invite_to_survey", :method => :post }
  end
  
  it "should map { :controller => 'organizations', :action => 'invite_to_network', :id => '1' } to /organizations/1/invite_to_network" do
    route_for(
      :controller => "organizations", 
      :action     => "invite_to_network", 
      :id         => '1').should == { :path => "/organizations/1/invite_to_network", :method => :post }
  end  
    
end

describe OrganizationsController, "handling GET /organizations/1" do

  before(:each) do
  
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)
      
    @organization = Factory.create(:organization)
    
  end
  
  def do_get
    get :show, :id => @organization.id
  end

  it "should require being logged in or invited to the survey" do
    controller.should_receive(:login_or_survey_invitation_required)
    do_get
  end
  
  it "should be successful" do    
    do_get
    response.should be_success
  end
  
  it "should render the show template" do  
    do_get
    response.should render_template('show')
  end
  
  it "should assign the organization requested for the view" do    
    do_get
    assigns[:organization].should == @organization
  end
  
  describe "when viewing self show page" do

    def do_get
      get :show, :id => @current_organization.id
    end    
  
    it "should redirect to the account edit page" do
      do_get
      response.should redirect_to(edit_account_path)
    end
    
  end
  
end

describe OrganizationsController, "handling GET /organizations/1 with external survey invitation" do

  before(:each) do
    
    @invitation = Factory.create(:external_survey_invitation)
    login_as(@invitation)
     
     @params = { :survey_id => @invitation.survey.id.to_s }
  end
  
  describe "when requesting the page of an invitee" do
   
    it "should assign the organization requested for the view" do    
     
      @invitee = Factory.create(:organization)
      
      Factory.create(:survey_invitation, 
        :invitee => @invitee, 
        :inviter => @invitation.survey.sponsor, 
        :survey  => @invitation.survey)
    
      get :show, @params.merge(:id => @invitee.id)
      assigns[:organization].should == @invitee
    end
     
  end
  
  describe "when requesting the page of the sponsor" do
    
    it "should assign the organization requested for the view" do    
      get :show, @params.merge(:id => @invitation.survey.sponsor.id)
      assigns[:organization].should == @invitation.survey.sponsor
    end
       
  end  
  
  describe "when requesting the page of a non-invitee" do
  
    it "should not find the requested organization" do 
      @non_invitee = Factory.create(:organization)         
      lambda{ get :show, @params.merge(:id => @non_invitee.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
      
  end  
  
end


describe OrganizationsController, "handling GET /organizations/search" do
  
  before(:each) do
  
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)
      
    @organization = Factory.create(:organization)    
    @organizations = [@organization]
        
    Organization.stub!(:search).and_return(@organizations)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/json"
    get :search, :search_text => "josh", :format => 'json'
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the organizations that match the search terms" do
    Organization.should_receive(:search).and_return(@organizations)
    do_get
  end
   
  it "should escape the search text" do
    Riddle.should_receive(:escape)
    do_get
  end
   
  it "should render the organization as JSON" do
    do_get
    response.body.should == @organizations.to_json(:only    => [:name, :location, :id, :contact_name],
                                                   :methods => 'name_and_location')
  end
  
  describe "when logged in as an association member" do
  
    before(:each) do
          
      @association = Factory.create(:association)
      controller.stub!(:current_association).and_return(@association)
        
    end
  
    it "should find the organizations that match the search terms for association/non-association members" do
      Organization.should_receive(:search).twice
      do_get
    end
    
    it "should append the 2 sets of search results together and render as JSON" do
      do_get
      response.body.should == [@organization,@organization].to_json(
        :only    => [:name, :location, :id, :contact_name],
        :methods => 'name_and_location')
    end
  
  end
    
end

describe OrganizationsController, "handling POST /organizations/1/invite_to_survey" do

  before(:each) do
  
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)
    
    @survey = Factory.create(:running_survey, :sponsor => @current_organization)    
    @other_organization = Factory(:organization)
    
  end
  
  def do_post
    post :invite_to_survey, { :id => @other_organization.id, :survey_id => @survey.id }
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post 
  end
  
  it "should create an internal invitation to the survey" do
    lambda{ do_post }.should change(@survey.invitations,:count).by(1)
  end
  
end

describe OrganizationsController, "handling POST /organizations/1/invite_to_network" do

  before(:each) do 
  
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @network = Factory(:network, :owner => @current_organization)    
    @other_organization = Factory(:organization)
  end
  
  def do_post
    post :invite_to_network, { :id => @other_organization.id, :network_id => @network.id }
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post
  end
  
  it "should create an internal invitation to the network" do
    lambda{ do_post }.should change(@network.invitations,:count).by(1)
  end
  
end

