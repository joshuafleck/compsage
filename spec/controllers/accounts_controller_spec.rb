require File.dirname(__FILE__) + '/../spec_helper'

describe AccountsController, "#route_for" do

  it "should map { :controller => 'accounts', :action => 'show' } to /accounts" do
    #route_for(:controller => "accounts", :action => "show").should == "/accounts"
  end

  it "should map { :controller => 'accounts', :action => 'edit'} to /accounts;edit" do
    #route_for(:controller => "accounts", :action => "edit").should == "/accounts;edit"
  end

  it "should map { :controller => 'accounts', :action => 'update'} to /accounts" do
    #route_for(:controller => "accounts", :action => "update").should == "/accounts"
  end

end

describe AccountsController, " handling GET /accounts" do
  it "should be successful"
  it "should render show template"
  it "should find account(organization)"
  it "should assign the found organization for the view"
end

describe AccountsController, " handling GET /accounts.xml" do
  it "should be successful"
  it "should find the account"
  it "should render the found account as XML"
end

describe AccountsController, " handling GET /accounts/edit" do
  it "should be successful"
  it "should render the edit template"
  it "should find the account requested"
  it "should assign the found account to the view"
end

describe AccountsController, " handling PUT /accounts" do
  it "should find the account requested"
  it "should update the selected account"
  it "should assign the found account to the view"
  it "should redirect to accounts default view"
end
