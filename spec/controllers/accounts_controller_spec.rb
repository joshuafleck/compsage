require File.dirname(__FILE__) + '/../spec_helper'

describe AccountsController, "#route_for" do

  it "should map { :controller => 'accounts', :action => 'show' } to /account" do
    #route_for(:controller => "accounts", :action => "show").should == "/account"
  end
  
  it "should map { :controller => 'accounts', :action => 'new' } to /account/new" do
    #route_for(:controller => "accounts", :action => "new").should == "/account/new"
  end  

  it "should map { :controller => 'accounts', :action => 'edit'} to /account/edit" do
    #route_for(:controller => "accounts", :action => "edit").should == "/account/edit"
  end

  it "should map { :controller => 'accounts', :action => 'update'} to /account" do
    #route_for(:controller => "accounts", :action => "update").should == "/account"
  end

end

describe AccountsController, " handling GET /account" do

  it "should be successful" do
  	pending
  end
  
  it "should render show template" do
  	pending
  end
  
  it "should find account(organization)" do
  	pending
  end
  
  it "should assign the found organization for the view" do
  	pending
  end
  
end

describe AccountsController, " handling GET /account/new" do

  it "should be successful" do
  	pending
  end
  
  describe "for the purposes of replying to a survey" do
  
  	it "should render the private new template"
  
  end
  
  describe "when creating a full account" do
  
  	it "should render the new template"
  
  end

end

describe AccountsController, " handling POST /account" do

	it "should create a new organization"
	
  describe "when the request is XML" do
  
  	it "should return a response regarding the success of the action" do
  		pending
  	end
  
  end
  
  describe "when the requst is HTML" do
  
  	it "should redirect to the account show page" do
  		pending
  	end
  	
  	it "should flash a message regarding the success of the action" do
  		pending
  	end
  
  end

end

describe AccountsController, " handling GET /account.xml" do

  it "should be successful" do
  	pending
  end
  
  it "should find the account" do
  	pending
  end
  
  it "should render the found account as XML" do
  	pending
  end
  
end

describe AccountsController, " handling GET /account/edit" do

  it "should be successful" do
  	pending
  end
  
  it "should render the edit template" do
  	pending
  end
  
  it "should find the account requested" do
  	pending
  end
  
  it "should assign the found account to the view" do
  	pending
  end
  
end

describe AccountsController, " handling PUT /account" do

  it "should find the account requested" do
  	pending
  end
  
  it "should update the selected account" do
  	pending
  end
	
  describe "when the request is XML" do
  
  	it "should return a response regarding the success of the action" do
  		pending
  	end
  
  end
  
	describe "when the request is HTML" do
		
	  it "should redirect to account show page" do
	  	pending
	  end
	  
	  it "should flash a message regarding the success of the edit" do
	  	pending
	  end
	  
  end
  
end
