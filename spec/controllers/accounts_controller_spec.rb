require File.dirname(__FILE__) + '/../spec_helper'

describe AccountsController, "#route_for" do

  it "should map { :controller => 'accounts', :action => 'show' } to /account" do
    route_for(:controller => "accounts", :action => "show").should == "/account"
  end
  
  it "should map { :controller => 'accounts', :action => 'new' } to /account/new" do
    route_for(:controller => "accounts", :action => "new").should == "/account/new"
  end  

  it "should map { :controller => 'accounts', :action => 'edit'} to /account/edit" do
    route_for(:controller => "accounts", :action => "edit").should == "/account/edit"
  end

  it "should map { :controller => 'accounts', :action => 'update'} to /account" do
    route_for(:controller => "accounts", :action => "update").should == "/account"
  end

end

describe AccountsController, " handling GET /account" do

  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
      
  end
  
  def do_get
    get :show
  end

  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should be successful" do
  	do_get
  	response.should be_success
  end
  
  it "should assign the organization to the view" do
    do_get
    assigns[:organization].should eql(@current_organization)
  end
  
  it "should render show template" do
  	do_get
  	response.should render_template("show")
  end
    
end

describe AccountsController, " handling GET /account.xml" do

  before(:each) do
    @current_organization = mock_model(Organization, :to_xml => "XML")
    login_as(@current_organization)
      
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :show
  end

  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should be successful" do
  	do_get
  	response.should be_success
  end
  
  it "should render the found account as XML" do
  	@current_organization.should_receive(:to_xml).and_return("XML")
  	do_get
  end
  
end

describe AccountsController, " handling GET /account/new" do

  before(:each) do
  
    @key = "1234"
  
    @organization = mock_model(Organization, :contact_name= => 'test', :email= => 'test', :name= => 'test')
    @external_invitation = mock_model(ExternalInvitation, :name => 'test', :email => 'test', :organization_name => 'test')
    
    Organization.stub!(:new).and_return(@organization)    
    Invitation.stub!(:find_by_key).with(@key).and_return(@external_invitation) 
    
    @params = {:key => @key}
    
    login_as_survey_invitation(false)
  end
  
  def do_get
    get :new, @params
  end

  it "should require a valid external invitation key" do
    Invitation.should_receive(:find_by_key).with(@key).and_return(@external_invitation)
    do_get
  end
  
  it "should be successful" do
  	do_get
  	response.should be_success
  end
  
  it "should render the new template" do
    do_get
    response.should render_template("new")
  end
  
  it "should create a new organization" do
    Organization.should_receive(:new).and_return(@organization)
    do_get
  end

  it "should assign the new organization to the view" do
    do_get
    assigns[:organization].should eql(@organization)
  end
  
end

describe AccountsController, " handling POST /account" do

  before(:each) do
  
    @key = "1234"
  
    @organization = mock_model(Organization, :save => true)
    @external_invitation = mock_model(ExternalInvitation, :name => 'test', :email => 'test', :is_a? => false)
    
    Invitation.stub!(:find_by_key).with(@key).and_return(@external_invitation) 
    Organization.stub!(:new).and_return(@organization)
    
    @organization.stub!(:set_logo).and_return(true)
    
    @params = {:key => @key}
    
  end
  
  def do_post
    get :create, @params
  end

  it "should require a valid external invitation key" do
    Invitation.should_receive(:find_by_key).with(@key).and_return(@external_invitation)
    do_post
  end
  
	it "should create a new organization" do
	  Organization.should_receive(:new).and_return(@organization)
	  @organization.should_receive(:save).and_return(true)
	  do_post
	end
	
	it "should save the organization's logo" do
	  @organization.should_receive(:set_logo)
	  do_post
	end

  describe "when the requst is HTML" do
  
  	it "should redirect to the login page" do
      do_post
      response.should redirect_to(new_session_path)
  	end
  	
  	it "should flash a message regarding the success of the action" do
      do_post
      flash[:notice].should eql("Your account was created successfully.")
  	end
  
  end

  it "should destroy the external invitation" do
    pending
  end

end

describe AccountsController, " handling POST /account with an external survey invitation" do

  before(:each) do
  
    @key = "1234"
  
    @organization = mock_model(Organization, :save => true)
    @survey = mock_model(Survey, :id => "1")
    @participation = mock_model(Participation, :survey => @survey)
    @participations = mock("participations proxy",:find => @participation, :count => 1)    
    @external_invitation = mock_model(ExternalSurveyInvitation, :survey => @survey, :name => 'test', :email => 'test')
    
    @external_invitation.stub!(:is_a?).with(ExternalSurveyInvitation).and_return(true)
    @external_invitation.stub!(:is_a?).with(ExternalNetworkInvitation).and_return(false)
    @external_invitation.stub!(:participations).and_return(@participations)
    @participations.stub!(:<<)
    @organization.stub!(:set_logo).and_return(true)
    @organization.stub!(:participations).and_return(@participations)
        
    Invitation.stub!(:find_by_key).with(@key).and_return(@external_invitation) 
    Organization.stub!(:new).and_return(@organization)
    SurveySubscription.stub!(:create!)
            
    @params = {:key => @key}
    
  end
  
  def do_post
    get :create, @params
  end

  it "should attribute the external invitation's survey participation to new organization" do
    @organization.should_receive(:participations).and_return(@participations)
    @participations.should_receive(:<<).with(@participation)
    do_post
  end
  
  it "should subscribe the new organization to the survey" do
    SurveySubscription.should_receive(:create!).with(
          :organization => @organization,
          :survey => @external_invitation.survey,
          :relationship => 'participant'
        )
     do_post
  end

end

describe AccountsController, " handling POST /account with an external network invitation" do
  before(:each) do

    @key = "1234"

    @organization = mock_model(Organization, :save => true)
    @network = mock_model(Network)
    @external_invitation = mock_model(ExternalNetworkInvitation, :network => @network, :name => 'test', :email => 'test')
    @networks = []
  
    @external_invitation.stub!(:is_a?).with(ExternalSurveyInvitation).and_return(false)
    @external_invitation.stub!(:is_a?).with(ExternalNetworkInvitation).and_return(true)
    Invitation.stub!(:find_by_key).with(@key).and_return(@external_invitation) 
    Organization.stub!(:new).and_return(@organization)

    @networks.stub!(:<<)
    @organization.stub!(:set_logo).and_return(true)
    @organization.stub!(:networks).and_return(@networks)

    @params = {:key => @key}

  end

  def do_post
    get :create, @params
  end

  it "should add the organization to the network" do
    @organization.should_receive(:networks).and_return(@networks)
    @networks.should_receive(:<<).with(@external_invitation.network)
    do_post
  end

end

describe AccountsController, " handling POST /account with validation error" do

  before(:each) do
  
    @key = "1234"
  
    @organization = mock_model(Organization, :save => false)
    @external_invitation = mock_model(ExternalInvitation, :name => 'test', :email => 'test')
    
    Invitation.stub!(:find_by_key).with(@key).and_return(@external_invitation) 
    Organization.stub!(:new).and_return(@organization)
    @organization.stub!(:set_logo)
    
    @params = {:key => @key}
    
  end
  
  def do_post
    get :create, @params
  end

  it "should render the new form" do
    do_post
    response.should render_template('new')
  end

end

describe AccountsController, " handling GET /account/edit" do

  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
        
  end
  
  def do_get
    get :edit
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
  	response.should render_template("edit")
  end
  
  it "should assign the organization to the view" do
    do_get
    assigns[:organization].should eql(@current_organization)
  end
  
end

describe AccountsController, " handling PUT /account" do
  
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @current_organization.stub!(:update_attributes).and_return(true)
    @current_organization.stub!(:set_logo).and_return(true)
    
  end
  
  def do_put
    put :update
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_put
  end
  
  it "should update the selected account" do
  	@current_organization.should_receive(:update_attributes).and_return(true)
  	do_put
  end

	it "should save the organization's logo" do
	  @current_organization.should_receive(:set_logo)
	  do_put
	end

	describe "when the request is HTML" do
		
	  it "should redirect to account show page" do
	  	do_put
	  	response.should redirect_to(account_path)
	  end
	  
	  it "should flash a message regarding the success of the edit" do
	    do_put
      flash[:notice].should eql("Your account was updated successfully.")
	  end
	  
  end
  
end
describe AccountsController, " handling PUT /account with validation error" do
  
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @current_organization.stub!(:update_attributes).and_return(false)
    @current_organization.stub!(:set_logo)
  end
  
  def do_put
    put :update
  end
  
  it "should render the edit form" do
    do_put
    response.should render_template('edit')
  end
  
end
