require File.dirname(__FILE__) + '/../helper'

RE_Organization      = %r{(?:(?:the )? *(\w+) *)}
RE_Organization_TYPE = %r{(?: *(\w+)? *)}
steps_for(:organization) do

  #
  # Setting
  #
  
  Given "an anonymous organization" do 
    log_out!
  end

  Given "$an $organization_type organization with $attributes" do |_, organization_type, attributes|
    create_organization! organization_type, attributes.to_hash_from_story
  end
  
  Given "$an $organization_type organization named '$login'" do |_, organization_type, login|
    create_organization! organization_type, named_organization(login)
  end
  
  Given "$an $organization_type organization logged in as '$login'" do |_, organization_type, login|
    create_organization! organization_type, named_organization(login)
    log_in_organization!
  end
  
  Given "$actor is logged in" do |_, login|
    log_in_organization! @organization_params || named_organization(login)
  end
  
  Given "there is no $organization_type organization named '$login'" do |_, login|
    @organization = Organization.find_by_login(login)
    @organization.destroy! if @organization
    @organization.should be_nil
  end
  
  #
  # Actions
  #
  When "$actor logs out" do 
    log_out
  end

  When "$actor registers an account as the preloaded '$login'" do |_, login|
    organization = named_organization(login)
    organization['password_confirmation'] = organization['password']
    create_organization organization
  end

  When "$actor registers an account with $attributes" do |_, attributes|
    create_organization attributes.to_hash_from_story
  end
  

  When "$actor logs in with $attributes" do |_, attributes|
    log_in_organization attributes.to_hash_from_story
  end
  
  #
  # Result
  #
  Then "$actor should be invited to sign in" do |_|
    response.should render_template('/sessions/new')
  end
  
  Then "$actor should not be logged in" do |_|
    controller.logged_in?.should_not be_true
  end
    
  Then "$login should be logged in" do |login|
    controller.logged_in?.should be_true
    controller.current_organization.should === @organization
    controller.current_organization.login.should == login
  end
    
end

def named_organization login
  organization_params = {
    'admin'   => {'id' => 1, 'login' => 'addie', 'password' => '1234addie', 'email' => 'admin@example.com',       },
    'oona'    => {          'login' => 'oona',   'password' => '1234oona',  'email' => 'unactivated@example.com'},
    'reggie'  => {          'login' => 'reggie', 'password' => 'monkey',    'email' => 'registered@example.com' },
    }
  organization_params[login.downcase]
end

#
# Organization account actions.
#
# The ! methods are 'just get the job done'.  It's true, they do some testing of
# their own -- thus un-DRY'ing tests that do and should live in the organization account
# stories -- but the repetition is ultimately important so that a faulty test setup
# fails early.  
#

def log_out 
  get '/sessions/destroy'
end

def log_out!
  log_out
  response.should redirect_to('/')
  follow_redirect!
end

def create_organization(organization_params={})
  @organization_params       ||= organization_params
  post "/organizations", :organization => organization_params
  @organization = Organization.find_by_login(organization_params['login'])
end

def create_organization!(organization_type, organization_params)
  organization_params['password_confirmation'] ||= organization_params['password'] ||= organization_params['password']
  create_organization organization_params
  response.should redirect_to('/')
  follow_redirect!

end



def log_in_organization organization_params=nil
  @organization_params ||= organization_params
  organization_params  ||= @organization_params
  post "/session", organization_params
  @organization = Organization.find_by_login(organization_params['login'])
  controller.current_organization
end

def log_in_organization! *args
  log_in_organization *args
  response.should redirect_to('/')
  follow_redirect!
  response.should have_flash("notice", /Logged in successfully/)
end
