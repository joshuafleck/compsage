require File.dirname(__FILE__) + '/../spec_helper'

describe PendingAccountsController, "#route_for" do

  it "should map { :controller => 'pending_accounts', :action => 'new' } to /pending_account/new" do
    route_for(:controller => "pending_accounts", :action => "new").should == "/signup"
  end  

end

describe PendingAccountsController, " handling GET /pending_account/new" do

  before(:each) do
    
    @pending_account = mock_model(PendingAccount)
    
    PendingAccount.stub!(:new).and_return(@pending_account)
    
  end

  def do_get
    get :new
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should create a new PendingAccount" do
    PendingAccount.should_receive(:new).and_return(@pending_account)
    do_get
  end
  
  it "should assign the new PendingAccount to the view" do
    do_get
    assigns[:pending_account].should eql(@pending_account)
  end
  
  it "should render the new template" do
    do_get
    response.should render_template("new")
  end

end

describe PendingAccountsController, " handling POST /pending_account" do

  before(:each) do
    
    @pending_account = mock_model(PendingAccount, :save => true)
    
    PendingAccount.stub!(:new).and_return(@pending_account)
    
  end
  
  def do_post
    post :create
  end

  it "should create a new pending account" do
    PendingAccount.should_receive(:new).and_return(@pending_account)
    @pending_account.should_receive(:save).and_return(true)
    do_post
  end

  describe "when the requst is HTML" do
  
    it "should redirect to the index page" do
      do_post
      response.should redirect_to('/')
    end
    
    it "should flash a message regarding the success of the action" do
      do_post
      flash[:notice].should eql("Your signup request was received.")
    end
  
  end
end

describe PendingAccountsController, " handling POST /pending_account with validation errors" do

  before(:each) do
    
    @pending_account = mock_model(PendingAccount, :save => false)
    
    PendingAccount.stub!(:new).and_return(@pending_account)
    
  end
  
  def do_post
    post :create
  end

  it "should render the new form" do
    do_post
    response.should render_template('new')
  end
  
end
