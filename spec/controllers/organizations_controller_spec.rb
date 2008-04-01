require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.

describe OrganizationsController, "#route_for" do
  it "should map { :controller => 'organizations'} to /organizations" do
    #route_for(:controller => "organizations").should == "/organizations"
    pending
  end
  
  it "should map { :controller => 'organizations', :action => 'show', :id => 1 } to /organizations/1" do
    route_for(:controller => "organizations", :action => "show", :id => 1).should == "/organizations/1"
  end
  
  it "should map { :controller => 'organizations', :action => 'destroy', :id => 1} to /organizations/1" do
    route_for(:controller => "organizations", :action => "destroy", :id => 1).should == "/organizations/1"
  end
  
  it "should map { :controller => 'organizations', :action => 'search'} to /organizations/search" do
    #route_for(:controller => "organizations", :action => "search", :id => 1).should == "/organizations/search"
    pending
  end
  
end

describe OrganizationsController, "handling GET /organizations/1" do
  it "should be successful"
  it "should render show template"
  it "should find the organization requested"
  it "should assign the organization requested for the view"
  #it "should return an error if the organization requested is private"
end

describe OrganizationsController, "handling GET /organizations/1.xml" do
  it "should be successful"
  it "should render the organization as xml"
  it "should find the organization requested"
  #it "should return an error if the organization requested is private"
end

describe OrganizationsController, "handling GET /organizations" do
  it "should be successful"
end

describe OrganizationsController, "handling GET /organizations/search" do
  it "should be successful"
  it "should render the search template"
  it "should find the organizations that match the search terms"
  #it "shouldn't find private organizations" -I don't believe we have private organizations anymore-JF
  it "should assign the found organizations for the view"
end
