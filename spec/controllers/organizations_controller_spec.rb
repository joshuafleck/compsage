require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.

describe OrganizationsController, "#route_for" do

  it "should map { :controller => 'organizations', :action => 'index'} to /organizations" do
    route_for(:controller => "organizations", :action => "index").should == "/organizations"
  end
  
  it "should map { :controller => 'organizations', :action => 'show', :id => '1' } to /organizations/1" do
    route_for(:controller => "organizations", :action => "show", :id => '1').should == "/organizations/1"
  end
  
  it "should map { :controller => 'organizations', :action => 'search'} to /organizations/search" do
    route_for(:controller => "organizations", :action => "search").should == "/organizations/search"
  end
  
end

describe OrganizationsController, " handling GET /organizations.xml" do

	before do

    @current_organization = mock_model(Organization)
    login_as(@current_organization)
      
    @organization = mock_model(Organization, :id => 1, :to_xml => "XML")
    
    Organization.stub!(:find).and_return(@organization)
    
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

  it "should find all organizations" do
    Organization.should_receive(:find).with(:all).and_return([@organization])
    do_get
  end
  
  it "should render the found organziations as xml" do
    @organization.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end

end

describe OrganizationsController, "handling GET /organizations/1" do

	before do
	
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
      
    @organization = mock_model(Organization, :id => 1, :name => "Organization Name")
    
    Organization.stub!(:find).and_return(@organization)
    
  end
  
  def do_get
    get :show, :id => "1"
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
  	response.should render_template('show')
  end
  
  it "should find the organization requested" do
  	Organization.should_receive(:find).with("1").and_return(@organization)
  	do_get
  end
  
  it "should assign the organization requested for the view" do  	
    do_get
    assigns[:organization].should equal(@organization)
  end
  
end

describe OrganizationsController, "handling GET /organizations/1.xml" do

	before do

    @current_organization = mock_model(Organization)
    login_as(@current_organization)
      
    @organization = mock_model(Organization, :id => 1, :to_xml => "XML", :name => "Organization Name")
    
    Organization.stub!(:find).and_return(@organization)
    
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :show, :id => "1"
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render the organization as xml" do  
    @organization.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
  
  it "should find the organization requested" do
  	Organization.should_receive(:find).with("1").and_return(@organization)
  	do_get
  end
  
end

describe OrganizationsController, "handling GET /organizations/search" do
	
	before do

    @current_organization = mock_model(Organization, :industry => 'Coal', :latitude => 1, :longitude => 1)
    login_as(@current_organization)
      
    @organization = mock_model(Organization, :id => 1, :name => "Denarius", :to_xml => "XML")
    @organizations = [@organization]
    Organization.stub!(:search).and_return(@organizations)
    @params = {:search_text => "josh"}
	end
  
  def do_get
    get :search, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should be successful" do
  	do_get
  	response.should be_success
  end
  
  it "should render the search template" do
  	do_get
  	response.should render_template('search')
  end
  
  it "should find the organizations that match the search terms" do
  	Organization.should_receive(:search).and_return(@organizations)
  	do_get
  end
  
  it "should assign the found organizations for the view" do
  	do_get
  	assigns[:organizations].should == [@organization]
  end
    
end

describe OrganizationsController, "handling GET /organizations/search without search text" do
	
	before do

    @current_organization = mock_model(Organization, :industry => 'Coal', :latitude => 1, :longitude => 1)
    login_as(@current_organization)
      
    @organization = mock_model(Organization, :id => 1, :name => "Denarius", :to_xml => "XML")
    @organizations = [@organization]
    Organization.stub!(:search).and_return(@organizations)
	end
  
  def do_get
    get :search
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should be successful" do
  	do_get
  	response.should be_success
  end
  
  it "should render the search template" do
  	do_get
  	response.should render_template('search')
  end
  
  it "should find the organizations that match the search terms" do
  	Organization.should_receive(:search).and_return(@organizations)
  	do_get
  end
  
  it "should assign the found organizations for the view" do
  	do_get
  	assigns[:organizations].should == [@organization]
  end
    
end

describe OrganizationsController, "handling PUT /organizations/1/invite_to_survey" do
  before do
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)
    
    @survey = Factory.create(:survey, :sponsor => @current_organization)
    @current_organization.sponsored_surveys.stub!(:find).and_return(@survey)
    
    @other_organization = Factory(:organization)
    Organization.stub!(:find).and_return(@other_organization)
  end
  
  def do_post
    post :invite_to_survey, :id => @other_organization.id, :survey_id => @survey.id
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post 
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

describe OrganizationsController, "handling PUT /organizations/1/invite_to_network" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    @network = Factory(:network, :owner => @current_organization)
    @current_organization.owned_networks.stub(:find).and_return(@network)
    
    @other_organization = Factory(:organization)
    Organization.stub!(:find).and_return(@other_organization)
  end
  
  def do_post
    post :invite_to_network, :id => @other_organization.id, :network_id => @network.id
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post
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

