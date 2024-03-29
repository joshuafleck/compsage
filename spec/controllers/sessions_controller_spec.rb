require File.dirname(__FILE__) + '/../spec_helper'


describe SessionsController do
  before(:each) do
    # set up an organization
    @brian = Organization.create(valid_organization_attributes)    
    @external_invitation = Factory.create(:external_survey_invitation)
    @internal_invitation = Factory.create(:survey_invitation)      
  end
  
  after(:each) do
    @brian.destroy
    @external_invitation.destroy
    @internal_invitation.destroy
  end
  
  it 'logins and redirects' do
    post :create, :email => valid_organization_attributes[:email], :password => valid_organization_attributes[:password]
    session[:organization_id].should_not be_nil
    response.should be_redirect
  end
  
  it 'logins and redirects when there is a valid survey invitation' do
    get :create_survey_session, :key => @external_invitation.key, :survey_id => @external_invitation.survey.id
    session[:external_survey_invitation_id].should eql(@external_invitation.id)
    response.should be_redirect
  end
  
  it 'fails login and does not redirect' do
    post :create, :email => valid_organization_attributes[:email], :password => 'bad password'
    session[:organization_id].should be_nil
    response.should render_template('new')
  end

  it 'fails login and does not redirect when the survey is invalid' do
    post :create_survey_session, :key => 'hahahahano', :survey_id => @external_invitation.survey.id
    response.should render_template('new')
  end
  
  it 'fails login when the organization is disabled' do
    disable_organization(@brian)
    post :create, :email => valid_organization_attributes[:email], :password => valid_organization_attributes[:password]
    session[:organization_id].should be_nil
    response.should be_redirect
  end

  it 'logs out' do
    login_as @brian
    get :destroy
    session[:organization_id].should be_nil
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
    response.cookies["auth_token"].should be_nil
  end

  it 'logs in with cookie' do
    @brian.remember_me
    @brian.save
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
  
  it 'fails cookie login when account is disabled' do
    @brian.remember_me
    disable_organization(@brian)
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
  
  it 'logins and redirects for an internal survey invitation' do
    get :create_survey_session, :key => @internal_invitation.key, :survey_id => @internal_invitation.survey.id
    session[:organization_id].should_not be_nil
    response.should be_redirect
  end  
  
  def auth_token(token)
    request.cookies['auth_token'] = token
  end
    
  def cookie_for(organization)
    auth_token organization.remember_token
  end
  
end

describe SessionsController, "handling POST /sessions (logging in)" do
  before(:each) do
    @org = Factory.create(:organization)
    @params = {:email => @org.email, :password => 'test12'}
  end
  
  after(:each) do
    @org.destroy
  end

  def do_post
    post :create, @params 
  end
  
  it "should update the organizations last logged in at time" do
    lambda { do_post }.should change { @org.reload; @org.last_login_at }
  end
  
  it "should set a session flag if this is the first time logging in" do
    do_post
    session[:first_login].should be_true
  end

  it "should not set a session flag if this is not the first time logging in" do
    @org.last_login_at = Time.now
    @org.save

    do_post
    session[:first_login].should be_nil
  end
end
