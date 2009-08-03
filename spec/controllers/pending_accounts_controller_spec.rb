require File.dirname(__FILE__) + '/../spec_helper'

describe PendingAccountsController, "#route_for" do
  it "should map { :controller => 'pending_accounts', :action => 'new' } to /pending_account/new" do
    route_for(:controller => "pending_accounts", :action => "new").should == "/signup"
  end  
end

describe PendingAccountsController, " handling GET /pending_account/new" do
  def do_get
    get :new
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should assign the new PendingAccount to the view" do
    do_get
    assigns[:pending_account].should_not be_nil
    assigns[:pending_account].should be_a(PendingAccount)
  end
  
  it "should render the new template" do
    do_get
    response.should render_template("new")
  end
end

describe PendingAccountsController, " handling POST /pending_account" do
  before(:all) do
    @valid_pending_account = Factory.build(:pending_account)
  end

  def do_post
    post :create, :pending_account => @valid_pending_account.attributes
  end

  it "should create a new pending account" do
    lambda { do_post }.should change(PendingAccount, :count).by(1)
  end

  
  it "should redirect to the index page" do
    do_post
    response.should redirect_to(new_session_path)
  end
  
  it "should flash a message regarding the success of the action" do
    do_post
    flash[:notice].should_not be_blank
  end
end

describe PendingAccountsController, " handling POST /pending_account with validation errors" do
  before do
    @invalid_pending_account = Factory.build(:pending_account, :email => nil)
  end
  
  def do_post
    post :create, :pending_account => @invalid_pending_account.attributes
  end

  it "should not save the record" do
    lambda { do_post }.should_not change(PendingAccount, :count)
  end

  it "should render the new form" do
    do_post
    response.should render_template('new')
  end
end
