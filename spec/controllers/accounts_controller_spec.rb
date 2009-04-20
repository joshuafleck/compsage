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
    route_for(:controller => "accounts", :action => "update").should == { :path => "/account", :method => :put }
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
    ExternalNetworkInvitation.stub!(:find_by_key).with(@key).and_return(@external_invitation) 
    
    @params = {:key => @key}
    
    login_as_survey_invitation(false)
  end
  
  def do_get
    get :new, @params
  end

  it "should require a valid external invitation key" do
    ExternalNetworkInvitation.should_receive(:find_by_key).with(@key).and_return(@external_invitation)
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
  
    @organization = mock_model(Organization, :save => true, :email => 'test@test.com', :last_login_at= => true)
    @external_invitation = mock_model(ExternalInvitation, :name => 'test', :email => 'test', :is_a? => false)
    
    ExternalInvitation.stub!(:find_by_key).with(@key).and_return(@external_invitation) 
    Organization.stub!(:new).and_return(@organization)
    Organization.stub!(:authenticate).and_return(@organization)
    
    @organization.stub!(:set_logo).and_return(true)
    
    @params = {:key => @key, :organization => {:password => "test12"}}
    
  end
  
  def do_post
    get :create, @params
  end

  it "should require a valid external invitation key" do
    ExternalInvitation.should_receive(:find_by_key).with(@key).and_return(@external_invitation)
    do_post
  end
  
	it "should create a new organization" do
	  Organization.should_receive(:new).and_return(@organization)
	  @organization.should_receive(:save).and_return(true)
	  do_post
	end
	
	it "should authenticate the organization" do
	  Organization.should_receive(:authenticate).and_return(@organization)
	  do_post
	end	
	
	it "should set the last login date" do
	  @organization.should_receive(:last_login_at=).and_return(true)
	  @organization.should_receive(:save).and_return(true)
	  do_post
	end

  describe "when the requst is HTML" do
  
  	it "should redirect to the surveys page" do
      do_post
      response.should redirect_to(surveys_path)
  	end
  	
  	it "should flash a message regarding the success of the action" do
      do_post
      flash[:notice].should eql("Your account was created successfully.")
  	end
  
  end

end

describe AccountsController, " handling POST /account with an external survey invitation" do

  before(:each) do
  
    @key = "1234"
  
    @organization = mock_model(Organization, :save => true, :email => 'test@test.com', :last_login_at= => true)
    @survey = mock_model(Survey, :id => "1")
    @participation = mock_model(Participation, :survey => @survey)
    @participations = mock('participations proxy', :count => 1) 
    @discussions = mock('discussions proxy') 
    @external_invitation = mock_model(
      ExternalSurveyInvitation, 
      :survey => @survey, 
      :name => 'test', 
      :email => 'test', 
      :save! => true)
    @survey_invitation = mock_model(
      SurveyInvitation, 
      :survey => @survey, 
      :name => 'test', 
      :email => 'test', 
      :save! => true,
      :aasm_state= => true)
    @survey_invitations = mock('survey invitations proxy')
    @discussion = mock_model(Discussion)
    
    @external_invitation.stub!(:is_a?).with(ExternalSurveyInvitation).and_return(true)
    @external_invitation.stub!(:is_a?).with(ExternalNetworkInvitation).and_return(false)
    @external_invitation.stub!(:participations).and_return([@participation])
    @external_invitation.stub!(:discussions).and_return([@discussion])
    @external_invitation.stub!(:type=).and_return('SurveyInvitation')
    @participations.stub!(:<<)
    @discussions.stub!(:<<)
    @survey_invitations.stub!(:<<)
    @organization.stub!(:set_logo).and_return(true)
    @organization.stub!(:participations).and_return(@participations)
    @organization.stub!(:discussions).and_return(@discussions)
    @organization.stub!(:survey_invitations).and_return(@survey_invitations)
        
    ExternalInvitation.stub!(:find_by_key).with(@key).and_return(@external_invitation) 
    Organization.stub!(:new).and_return(@organization)
    Organization.stub!(:authenticate).and_return(@organization)
    SurveySubscription.stub!(:create!)
    SurveyInvitation.stub!(:find).and_return(@survey_invitation)
            
    @params = {:key => @key, :organization => {:password => "test12"}}
    
  end
  
  def do_post
    get :create, @params
  end

  it "should attribute the external invitation's survey participation to new organization" do
    @external_invitation.should_receive(:participations)
    @participations.should_receive(:<<).with(@participation)
    do_post
  end
  
  it "should attribute the external invitation's discussions to new organization" do
    @external_invitation.should_receive(:discussions)
    @discussions.should_receive(:<<).with(@discussion)
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
  
  it "should change the external survey invitation to a survey invitation" do
    @external_invitation.should_receive(:type=)
    @external_invitation.should_receive(:save!)
    do_post
  end
  
  it "should add the new organization to the survey invitation" do
    @survey_invitations.should_receive(:<<).with(@survey_invitation)
    do_post
  end

end

describe AccountsController, " handling POST /account with an external network invitation" do
  before(:each) do

    @key = "1234"

    @organization = mock_model(Organization, :save => true, :email => 'test@test.com', :last_login_at= => true)
    @network = mock_model(Network)
    @external_invitation = mock_model(
      ExternalNetworkInvitation, 
      :network => @network, 
      :name => 'test', 
      :email => 'test',
      :destroy => true)
    @networks = []
  
    @external_invitation.stub!(:is_a?).with(ExternalSurveyInvitation).and_return(false)
    @external_invitation.stub!(:is_a?).with(ExternalNetworkInvitation).and_return(true)
    ExternalInvitation.stub!(:find_by_key).with(@key).and_return(@external_invitation) 
    Organization.stub!(:new).and_return(@organization)
    Organization.stub!(:authenticate).and_return(@organization)

    @networks.stub!(:<<)
    @organization.stub!(:set_logo).and_return(true)
    @organization.stub!(:networks).and_return(@networks)

    @params = {:key => @key, :organization => {:password => "test12"}}

  end

  def do_post
    get :create, @params
  end

  it "should add the organization to the network" do
    @organization.should_receive(:networks).and_return(@networks)
    @networks.should_receive(:<<).with(@external_invitation.network)
    do_post
  end
  
  it "should destroy the external invitation" do
    @external_invitation.should_receive(:destroy)
    do_post
  end

end

describe AccountsController, " handling POST /account with validation error" do

  before(:each) do
  
    @key = "1234"
  
    @organization = mock_model(Organization, :save => false)
    @external_invitation = mock_model(ExternalInvitation, :name => 'test', :email => 'test')
    
    ExternalInvitation.stub!(:find_by_key).with(@key).and_return(@external_invitation) 
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

	describe "when the request is HTML" do
		
	  it "should redirect to account show page" do
	  	do_put
	  	response.should redirect_to(edit_account_path)
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

describe AccountsController, "handing" do
  
end
