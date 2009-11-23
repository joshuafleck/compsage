require File.dirname(__FILE__) + '/../spec_helper'

describe AssociationsController, "#route_for" do

  it "should map { :controller => 'associations', :action => 'sign_in' } to associations/sign_in" do
    route_for(:controller => "associations", :action => "sign_in").should == "associations/sign_in"
  end
  
  it "should map { :controller => 'associations', :action => 'edit' } to associations/edit" do
    route_for(:controller => "associations", :action => "edit").should == "associations/edit"
  end
  
  it "should map { :controller => 'associations', :action => 'show' } to associations" do
    route_for(:controller => "associations", :action => "show").should == "associations"
  end
  
end

describe AssociationsController, "handling GET /associations/2/sign_in" do

  before(:each) do
  
    @association = Factory.create(:association)
    controller.stub!(:current_association).and_return(@association)
  end
  
  def do_get
    get :sign_in, :id => @association.id
  end
  
  it "should be successful" do    
    do_get
    response.should be_success
  end
  
  it "should redirect to association page if already authenticated" do
    session[:association_id] = @association.id
    do_get
    response.should be_redirect
  end
  
end

describe AssociationsController, "handling POST /associations/2/sign_in" do

  before(:each) do
  
    @association = Factory(:association)
    controller.stub!(:current_association).and_return(@association)
    @params = {:email => @association.owner_email, :id => @association.id}
  end
  
  def do_post
    post :sign_in, @params
  end
  
  it "should render the sign in page when the authentication fails" do
    do_post
    response.should render_template('sign_in')
  end  

  it "should login in the owner and redirect to the association page" do
    @params[:password] = "test12"
    do_post
    session[:association_id].should_not be_nil
    response.should be_redirect
  end
  
end