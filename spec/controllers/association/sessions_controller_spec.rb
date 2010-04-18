require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
describe Association::SessionsController, "#route_for" do

  it "should map { :controller => 'association/sessions', :action => 'new' } to /association/session/new" do
    route_for(:controller => "association/sessions", :action => "new").should == "/association/session/new"
  end
  
  it "should map { :controller => 'association/sessions', :action => 'create' } to /association/session" do
    route_for(:controller => "association/sessions", :action => "create").should == { :path => "/association/session", :method => :post }
  end
  
  it "should map { :controller => 'association/sessions', :action => 'destroy' } to /association/session" do
    route_for(:controller => "association/sessions", :action => "destroy").should == { :path => "/association/session", :method => :delete }
  end
  
end

describe Association::SessionsController, "getting the login form (new)" do
  def do_get
    get :new
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render the new template" do
    do_get
    response.should render_template('new')
  end
  
  describe "when already logged in" do
    it "should redirect to association members path" do
      login_as(Factory(:association))
      do_get
      
      response.should redirect_to(association_members_path)
    end
  end
end

describe Association::SessionsController, "handling logging in (create)" do
  before(:each) do
    @association = Factory(:association)
  end
  
  def do_post
    post :create, @params
  end
  
  describe "with valid credentials" do
    before(:each) do
      @params = {:password => 'test12', :email => @association.contact_email}
      do_post
    end
    
    it "should redirect to association path" do
      response.should redirect_to('association')
    end
    
    it "should be logged in" do
      controller.send(:logged_in_as_association_owner?).should be_true
    end
    
    it "should set the association id in the session" do
      session[:association_id].should_not be_nil
    end
  end
  
  describe "with invalid credentials" do
    before(:each) do
      @params = {:password => 'WRONG', :email => @association.contact_email}
      do_post
    end
    
    it "should render the new session path" do
      response.should render_template('new')
    end
    
    it "should not be logged in" do
      controller.send(:logged_in_as_association_owner?).should be_false
    end
    
    it "should not set the association id in the session" do
      session[:association_id].should be_nil
    end
  end
end

describe Association::SessionsController, "handling logging out (destroy)" do
  before(:each) do
    @association = Factory(:association)
  end
  
  def do_destroy
    get :destroy
  end
  
  describe "with an active session" do
    before(:each) do
      login_as(:association)
      do_destroy
    end
    
    it "should redirect to association path" do
      response.should redirect_to('association')
    end
    
    it "should no longer be logged in" do
      controller.send(:logged_in_as_association_owner?).should be_false
    end
    
    it "should remove the association id in the session" do
      session[:association_id].should be_nil
    end
  end
  
  describe "without an active session" do 
    before(:each) do
      do_destroy
    end
    
    it "should redirect to association path" do
      response.should redirect_to('association')
    end
  end
end