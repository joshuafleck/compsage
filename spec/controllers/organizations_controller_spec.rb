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

describe OrganizationsController, " handling sign up stuff" do
  fixtures :organizations

  it 'allows signup' do
    lambda do
      create_organization
      response.should be_redirect      
    end.should change(Organization, :count).by(1)
  end

  it 'requires password on signup' do
    lambda do
      create_organization(:password => nil)
      assigns[:organization].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(Organization, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_organization(:password_confirmation => nil)
      assigns[:organization].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(Organization, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_organization(:email => nil)
      assigns[:organization].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(Organization, :count)
  end
  
  it "should redirect to dashboard"
  
  def create_organization(options = {})
    post :create, :organization => { :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire' }.merge(options)
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