require File.dirname(__FILE__) + '/../spec_helper'


describe SessionsController do
  before(:all) do
    # set up an organization
    @brian = Organization.new(valid_organization_attributes)
    @brian.save
  end
  
  after(:all) do
    @brian.destroy
  end
  
  it 'logins and redirects' do
    post :create, :email => valid_organization_attributes[:email], :password => valid_organization_attributes[:password]
    session[:organization_id].should_not be_nil
    response.should be_redirect
  end
  
  it 'fails login and does not redirect' do
    post :create, :email => valid_organization_attributes[:email], :password => 'bad password'
    session[:organization_id].should be_nil
    response.should render_template('new')
  end

  it 'logs out' do
    login_as @brian
    get :destroy
    session[:organization_id].should be_nil
    response.should be_redirect
  end

  it 'remembers me' do
    post :create, :email => valid_organization_attributes[:email], :password => valid_organization_attributes[:password], :remember_me => "1"
    response.cookies["auth_token"].should_not be_nil
  end
  
  it 'does not remember me' do
    post :create, :email => valid_organization_attributes[:email], :password => valid_organization_attributes[:password], :remember_me => "0"
    response.cookies["auth_token"].should be_nil
  end

  it 'deletes token on logout' do
    login_as @brian
    get :destroy
    response.cookies["auth_token"].should == []
  end

  it 'logs in with cookie' do
    @brian.remember_me
    request.cookies["auth_token"] = cookie_for(@brian)
    get :new
    controller.send(:logged_in?).should be_true
  end
  
  it 'fails expired cookie login' do
    @brian.remember_me
    @brian.update_attribute :remember_token_expires_at, 5.minutes.ago
    request.cookies["auth_token"] = cookie_for(@brian)
    get :new
    controller.send(:logged_in?).should_not be_true
  end
  
  it 'fails cookie login' do
    @brian.remember_me
    request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    controller.send(:logged_in?).should_not be_true
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
    
  def cookie_for(organization)
    auth_token organization.remember_token
  end
  
end

describe SessionsController, "handling POST /sessions (logging in)" do
  it "should update the organizations last logged in at time"
end
