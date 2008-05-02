require File.dirname(__FILE__) + '/../spec_helper'

describe PendingAccountsController, "#route_for" do

  it "should map { :controller => 'pending_accounts', :action => 'new' } to /pending_account/new" do
    #route_for(:controller => "pending_accounts", :action => "new").should == "/pending_account/new"
    pending
  end  

end

describe PendingAccountsController, " handling GET /pending_account/new" do

  it "should be successful" do
    pending
  end
  
  it "should render the new template" do
    pending
  end

end

describe PendingAccountsController, " handling POST /pending_account" do

  it "should create a new pending account" do
    pending
  end

  describe "when the requst is HTML" do
  
    it "should redirect to the index page" do
      pending
    end
    
    it "should flash a message regarding the success of the action" do
      pending
    end
  
  end

end
