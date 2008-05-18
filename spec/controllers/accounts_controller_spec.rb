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
  
    @organization = mock_model(Organization)
    @external_invitation = mock_model(ExternalInvitation)
    
    Organization.stub!(:new).and_return(@organization)    
    ExternalInvitation.stub!(:find_by_key).with(@key).and_return(@external_invitation) 
    
    @params = {:key => @key}
  end
  
  def do_get
    get :new, @params
  end

  it "should require a valid external invitation key" do
    ExternalInvitation.should_receive(:find_by_key).with(@key).and_return(@external_invitation)
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
  
    @organization = mock_model(Organization)
    @external_invitation = mock_model(ExternalInvitation)
    
    ExternalInvitation.stub!(:find_by_key).with(@key).and_return(@external_invitation) 
    Organization.stub!(:create!)
    
    @params = {:key => @key}
    
  end
  
  def do_post
    get :create, @params
  end

  it "should require a valid external invitation key" do
    ExternalInvitation.should_receive(:find_by_key).with(@key).and_return(@external_invitation)
    do_post
  end
  
	it "should create a new organization" do
	  Organization.should_receive(:create!)
	  do_post
	end

 	it "should return a response regarding the success of the action when the request is XML" do
 		pending
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
    @current_organization = mock_model(Organization, :update_attributes! => true)
    login_as(@current_organization)
    
  end
  
  def do_put
    put :update
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_put
  end
  
  it "should update the selected account" do
  	@current_organization.should_receive(:update_attributes!)
  	do_put
  end

  it "should return a response regarding the success of the action when the request is XML" do
  	pending
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
