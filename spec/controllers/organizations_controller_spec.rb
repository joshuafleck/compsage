require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.

describe OrganizationsController, "#route_for" do
  
  it "should map { :controller => 'organizations', :action => 'new' } to /organizations/new" do
    route_for(:controller => "organizations", :action => "new").should == "/organizations/new"
  end
  
  it "should map { :controller => 'organizations', :action => 'show', :id => 1 } to /organizations/1" do
    route_for(:controller => "organizations", :action => "show", :id => 1).should == "/organizations/1"
  end
  
  it "should map { :controller => 'organizations', :action => 'destroy', :id => 1} to /organizations/1" do
    route_for(:controller => "organizations", :action => "destroy", :id => 1).should == "/organizations/1"
  end
  
end

describe OrganizationsController, "handling GET /organizations/1" do
  it "should be successful"
  it "should render show template"
  it "should find the organization requested"
  it "should assign the organization requested for the view"
end

describe OrganizationsController, "handling GET /organizations/1.xml" do
  it "should be successful"
  it "should render the organization as xml"
  it "should find the organization requested"
end