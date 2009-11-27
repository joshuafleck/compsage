require File.dirname(__FILE__) + '/../spec_helper'

describe AssociationMembersController, "#route_for" do

  it "should map { :controller => 'association_members', :action => 'sign_in' } to /" do
    route_for(:controller => "association_members", :action => "sign_in").should == "/"
  end
  
  it "should map { :controller => 'association_members', :action => 'sign_in' } to /association_member/sign_in" do
    route_for(:controller => "association_members", :action => "sign_in").should == "/association_member/sign_in"
  end 
  
  it "should map { :controller => 'association_members', :action => 'login_received' } to /association_member/login_received" do
    route_for(:controller => "association_members", :action => "login_received").should == "/association_member/login_received"
  end 
  
  it "should map { :controller => 'association_members', :action => 'initialize_account' } to /association_member/initialize_account" do
    route_for(:controller => "association_members", :action => "initialize_account").should == "/association_member/initialize_account"
  end   
  
end  

describe AssociationMembersController, "handling GET /association_member/sign_in" do

  before(:each) do
  
    @association = Factory.create(:association)
    @login = "test@example.com"
    controller.stub!(:current_association).and_return(@association)
    
  end
  
  def do_get
    get :sign_in, :email => @login
  end
  
  it "should be successful" do    
    do_get
    response.should be_success
  end

  it "should require an association" do
    controller.stub!(:current_association).and_return(nil)
    do_get
    assert_response 404
  end
  
  it "should assign the login to the view" do
    do_get
    assigns[:login].should == @login
  end
  
end  

describe AssociationMembersController, "handling POST /association_member/sign_in" do

  before(:each) do
  
    @association                = Factory.create(:association)
    @uninitialized_organization = Factory.create(:uninitialized_association_member)
    @organization               = Factory.create(:organization)
    controller.stub!(:current_association).and_return(@association)
    
    @params = {}
  end
  
  def do_post
    post :sign_in, @params
  end

  it "should render the sign in page when the user is not an association member" do
    do_post
    response.should render_template('sign_in')
  end
  
  describe "when authenticating an initialized organization" do
    before(:each) do        
      @remember_me = "1"
      @association.organizations << @organization
      @params[:email] = @organization.email
      @params[:remember_me] = @remember_me
    end
  
    it "should render the sign in page when the authentication fails" do
      do_post
      response.should render_template('sign_in')
    end  
    
    it "should assign the 'remember me' flag to the view" do
      do_post
      assigns[:remember_me].should == @remember_me
    end
    
    it "logins and redirects" do
      @params[:password] = "test12"
      do_post
      session[:organization_id].should_not be_nil
      response.should be_redirect
    end    
    
  end
  
  describe "when authenticating an uninitialized association member" do
    before(:each) do    
      @association.organizations << @uninitialized_organization
      @params[:email] = @uninitialized_organization.email
    end
   
    it "should render the sign in page when login creation fails" do
      do_post
      response.should render_template('sign_in')
    end 
    
    it "should assign the association member to the view" do
      do_post
      assigns[:association_member].should == @uninitialized_organization
    end
    
    it "should render the sign in page if the association member has recently requested initialization" do
      @uninitialized_organization.association_member_initialization_key_created_at = Time.now
      @uninitialized_organization.save!
      do_post
      response.should render_template('sign_in')
    end
    
    it "should redirect to the login received page if the association member when the login is created" do
      @params[:password] = "test12"
      @params[:password_confirmation] = @params[:password]
      do_post
      response.should be_redirect
    end    
   
  end  
    
end

describe AssociationMembersController, "handling GET /association_member/login_received" do

  before(:each) do
  
    @association = Factory.create(:association)
    controller.stub!(:current_association).and_return(@association)
    
  end
  
  def do_get
    get :login_received
  end
  
  it "should be successful" do    
    do_get
    response.should be_success
  end

  it "should require an association" do
    controller.stub!(:current_association).and_return(nil)
    do_get
    assert_response 404
  end
    
end 

describe AssociationMembersController, "handling GET /association_member/initialize_account" do

  before(:each) do
  
    @association = Factory.create(:association)
    controller.stub!(:current_association).and_return(@association)
    
    @organization = Factory.create(:uninitialized_association_member)
    @organization.create_login(@association, { :password => 'test12', :password_confirmation => 'test12'})
    
    @association.organizations << @organization
    
    @params = { :key => @organization.association_member_initialization_key }
  end
  
  def do_get
    get :initialize_account, @params
    @organization.reload
  end
  
  it "should require an association" do
    controller.stub!(:current_association).and_return(nil)
    do_get
    assert_response 404
  end
  
  it "should unset the uninitialized flag on the association member" do
    lambda{ do_get }.should change(@organization, :is_uninitialized_association_member).from(true).to(false)
  end
  
  it "should render the new session path if the organization is not a member of the current association" do
    @params[:key]='blah'
    do_get
    response.should render_template('sign_in')
  end
  
  it "should log the user in" do
    do_get
    session[:organization_id].should_not be_nil
    response.should be_redirect
  end
    
end
