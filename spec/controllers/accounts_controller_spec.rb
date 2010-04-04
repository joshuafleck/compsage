require File.dirname(__FILE__) + '/../spec_helper'

describe AccountsController, "#route_for" do

  it "should map { :controller => 'accounts', :action => 'show' } to /account" do
    route_for(:controller => "accounts", :action => "show").should == "/account"
  end
  
  it "should map { :controller => 'accounts', :action => 'new' } to /account/new" do
    route_for(:controller => "accounts", :action => "new").should == "/account/new"
  end  

  it "should map { :controller => 'accounts', :action => 'edit'} to /account/edit" do
    route_for(:controller => "accounts", :action => "edit").should == "/account/edit"
  end

  it "should map { :controller => 'accounts', :action => 'update'} to /account" do
    route_for(:controller => "accounts", :action => "update").should == { :path => "/account", :method => :put }
  end

  it "should map { :controller => 'accounts', :action => 'reset'} to /account/reset" do
    route_for(:controller => "accounts", :action => "reset").should == "/account/reset"
  end

  it "should map { :controller => 'accounts', :action => 'forgot'} to /account/forgot" do
    route_for(:controller => "accounts", :action => "forgot").should == "/account/forgot"
  end
  
  it "should map { :controller => 'accounts', :action => 'activate'} to /account/activate" do
    route_for(:controller => "accounts", :action => "activate").should == "/account/activate"
  end  

  it "should map { :controller => 'accounts', :action => 'deactivate'} to /account/deactivate" do
    route_for(:controller => "accounts", :action => "deactivate").should == "/account/deactivate"
  end  

end

describe AccountsController, " handling GET /account/new" do

  it "should look for an invitation" do
    controller.should_receive(:locate_invitation)
    get :new
  end

  describe "when invited to a network" do

    before(:each) do
      @invitation = Factory.create(:external_network_invitation)
    end
    
    after(:each) do
      @invitation.destroy
    end
    
    def do_get
      get :new, :key => @invitation.key
    end
    
    it "should be successful" do    
      do_get
      response.should be_success
    end
    
    it "should render the new template" do  
      do_get
      response.should render_template('new')
    end
     
    it "should assign a new organization to the view" do
      do_get
      assigns[:organization].should_not be_blank
    end  
         
    it "should assign the invitation to the view" do
      do_get
      assigns[:invitation].should == @invitation
    end
     
    it "should assign the invitation to the session" do
      do_get
      session[:invitation].should == @invitation
    end
     
  end
  
  describe "when invited to a survey" do
  
    before(:each) do
      @invitation = Factory.create(:external_survey_invitation)
      login_as(@invitation)
    end
    
    after(:each) do
      @invitation.destroy
    end
    
    def do_get
      get :new, :survey_id => @invitation.survey.id.to_s
    end   
      
    it "should assign the invitation to the view" do
      do_get
      assigns[:invitation].should == @invitation
    end
     
    it "should be successful" do    
      do_get
      response.should be_success
    end
     
    it "should assign a new organization to the view" do
      do_get
      assigns[:organization].should_not be_blank
    end  
     
    it "should render the new template" do  
      do_get
      response.should render_template('new')
    end
        
  end
  
  describe "when the invitation is saved in the session" do
  
    before(:each) do
      @invitation = Factory.create(:external_network_invitation)
      session[:invitation] = @invitation
    end
    
    after(:each) do
      @invitation.destroy
    end  
  
    it "should assign the invitation to the view" do
      get :new
      assigns[:invitation].should == @invitation
    end
     
    it "should be successful" do    
      get :new
      response.should be_success
    end
     
    it "should assign a new organization to the view" do
      get :new
      assigns[:organization].should_not be_blank
    end  
     
    it "should render the new template" do  
      get :new
      response.should render_template('new')
    end
    
    describe "when the invitee is already a member" do
    
      before(:each) do
        @organization = Factory.create(:organization, :email => @invitation.email)
      end
      
      after(:each) do
        @organization.destroy
      end  
      
      it "should redirect to the sign in page" do
        get :new
        response.should redirect_to(login_path(:email => @organization.email))
      end
    
    end
        
  end  
  
end

describe AccountsController, " handling GET /account/activate" do

  before(:each) do
    @current_organization = Factory.create(:pending_organization)
    @params = { :key => @current_organization.activation_key }
  end
  
  def do_get
    get :activate, @params
    @current_organization.reload
  end
  
  it "should redirect to the edit account page" do    
    do_get
    response.should redirect_to(edit_account_path)
  end
  
  it "should activate the organization" do  
    lambda{ do_get }.should change(@current_organization, :activated?).from(false).to(true)
  end
  
  it "should redirect to the login page if the organization is not found" do
    @params[:key] = '1234'
    do_get
    response.should redirect_to(new_session_path)
  end
  
  it "should move external survey invitations to the activated organization with the same email" do
    invitation = Factory(:external_survey_invitation, :email => @current_organization.email)
    lambda{ do_get }.should change(ExternalSurveyInvitation, :count).from(1).to(0)
    invitation.destroy
  end
 
end  

describe AccountsController, " handling GET /account/edit" do

  before(:each) do
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)
  end
  
  it "should be successful" do    
    get :edit
    response.should be_success
  end
  
  it "should render the edit template" do  
    get :edit
    response.should render_template('edit')
  end
  
  it "should require login" do
    controller.should_receive(:login_required)
    get :edit
  end
  
  it "should assign the current organization to the view" do
    get :edit
    assigns[:organization].should == @current_organization
  end 
end  

describe AccountsController, " handling POST /account/" do

  before(:each) do
    
    @organization = Factory.build(:organization)
    
    @invitation2 = Factory.create(:external_survey_invitation, :email => @organization.email)
      
    @params = { :organization => @organization.attributes }
    @params[:organization] = @params[:organization].merge(:password => "123456")
    @params[:organization] = @params[:organization].merge(:password_confirmation => "123456")
  end

  def do_post
    post :create, @params
  end 
  
  it "should redirect to the survey index" do  
    do_post
    response.should be_redirect
  end
  
  it "should create the organization" do  
    lambda{ do_post }.should change(Organization,:count).by(1)
  end
  
  describe "with inviation" do
  
    before(:each) do
      @invitation = Factory.create(:external_survey_invitation)
      login_as(@invitation)
            
      @params[:survey_id] = @invitation.survey.id.to_s
    end  
     
    after(:each) do
      @invitation.destroy
      @invitation2.destroy
    end
       
    it "should accept the invitation" do  
      @invitation.should_receive(:accept!)
      do_post
    end 
         
    it "should find any previous external survey invitations an accept them as well" do  
      lambda{ do_post }.should change(ExternalSurveyInvitation,:count).from(2).to(0)
    end 
            
    it "should find any previous external network invitations an accept them as well" do  
      @network_invitation = Factory.create(:external_network_invitation, :email => @organization.email)
      lambda{ do_post }.should change(ExternalNetworkInvitation,:count).from(1).to(0)
    end 
        
    it "should not create a pending organization"   do 
      do_post
      assigns[:organization].pending?.should be_false
    end
    
    it "should create an organization that does not require activation" do
      do_post
      assigns[:organization].activated?.should be_true
    end
  
  end
 
  it "should find not accept any previous external survey invitations" do  
    lambda{ do_post }.should_not change(ExternalSurveyInvitation,:count)
  end 
        
  
  it "should create a pending organization"   do 
    do_post
    assigns[:organization].pending?.should be_true
  end
  
  it "should create an organization that requires activation" do
    do_post
    assigns[:organization].activated?.should be_false
  end  
  
  it "should send a new organization notification" do
    Notifier.should_receive(:deliver_new_organization_notification)
    do_post
  end   
   
  it "should log the user in" do  
    do_post
    session[:organization_id].should_not be_blank
  end
  
  it "should set the first login flag" do  
    do_post
    session[:first_login].should be_true
  end

  # TODO this is failing because it can't find the invitation, not sure why this is
  #it "should require an invitation" do
  #  controller.should_receive(:invitation_or_pending_account_required)
  #  do_post
  #end

  it "should assign the current organization to the view" do
    do_post
    assigns[:organization].should_not be_blank
  end 
  
  describe "with failure" do
  
    it "should render the new template" do
      @params[:organization][:password] = ''
      do_post
      response.should render_template('new')
    end
  
  end
  
end 

describe AccountsController, " handling PUT /account/" do

  before(:each) do
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)
    
    @params = { :organization => @current_organization.attributes }
  end
  
  after(:each) do
    @current_organization.destroy
  end
  
  def do_put
    put :update, @params
  end 
  
  it "should redirect to the edit account path" do  
    do_put
    response.should redirect_to(edit_account_path)
  end
  
  it "should flash a success message" do  
    do_put
    flash[:notice].should_not be_blank
  end

  it "should update the organization" do  
    @current_organization.should_receive(:update_attributes)
    do_put
  end

  it "should require login" do
    controller.should_receive(:login_required)
    do_put
  end

  it "should assign the current organization to the view" do
    do_put
    assigns[:organization].should == @current_organization
  end 
  
  describe "with failure" do
  
    it "should render the edit template" do
      @params[:organization][:name] = ''
      do_put
      response.should render_template('edit')
    end
  
  end
  
end 

describe AccountsController, " handling GET /account/forgot" do

  it "should be successful" do
    get :forgot
    response.should be_success
  end
  
  it "should render the forgot template" do
    get :forgot
    response.should render_template('forgot')
  end  
  
end 

describe AccountsController, " handling PUT /account/forgot" do

  before(:each) do
    @current_organization = Factory.create(:organization)    
  end
  
  after(:each) do
    @current_organization.destroy
  end
  
  def do_put
    put :forgot, :email => @current_organization.email
    @current_organization.reload
  end 
  
  it "should find the organization" do
    Organization.should_receive(:find_by_email).with(@current_organization.email).and_return(@current_organization)
    do_put
  end
  
  it "should create the reset key and send the reset email" do
    lambda{ do_put }.should change(@current_organization,:reset_password_key).from(nil)
  end  
  
  it "should redirect to the new session path" do  
    do_put
    response.should redirect_to(new_session_path)
  end
  
  it "should flash a success message" do  
    do_put
    flash[:notice].should_not be_blank
  end
  
  describe "when the organization is not found" do
  
    # TODO flash.now apparently can not be tested this way
    #it "should flash a message" do
    #  put :forgot
    #  flash[:notice].should_not be_blank
    #end
    
    it "should render the forgot template" do
      put :forgot
      response.should render_template('forgot')
    end
  
  end
  
  describe "when there is already a valid reset request" do
  
    before(:each) do
      @current_organization.create_reset_key_and_send_reset_notification
    end
    
    it "should not create the reset key and send the reset email" do
      lambda{ do_put }.should_not change(@current_organization,:reset_password_key).from(nil)
    end      
  
    it "should render the forgot template" do
      do_put
      response.should render_template('forgot')
    end
    
  end

end 

describe AccountsController, " handling GET /account/reset" do

  before(:each) do
    @organization = Factory.create(:organization)
    @organization.create_reset_key_and_send_reset_notification
  end
  
  after(:each) do
    @organization.destroy
  end
  
  def do_get
    get :reset, :key => @organization.reset_password_key
    @organization.reload
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render the reset template" do
    do_get
    response.should render_template('reset')
  end  
  
  it "should assign the organization to the view" do
    do_get
    assigns[:organization].should == @organization
  end 
  
  describe "when the organization is not found" do
   
    it "should redirect to the new session path" do  
      get :reset
      response.should redirect_to(new_session_path)
    end
     
    it "should flash a message" do  
      get :reset
      flash[:notice].should_not be_blank
    end
     
  end 
  
  describe "when the reset key has expired" do
  
    before(:each) do
      @organization.reset_password_key_expires_at = Time.now - 1.minute
      @organization.save!
    end  
   
    it "should redirect to the new session path" do  
      do_get
      response.should redirect_to(new_session_path)
    end
     
    it "should flash a message" do  
      do_get
      flash[:notice].should_not be_blank
    end
      
    it "should delete the reset key" do  
      lambda{ do_get }.should change(@organization,:reset_password_key).to(nil)
    end
         
  end   
  
end 

describe AccountsController, " handling PUT /account/reset" do

  before(:each) do
    @organization = Factory.create(:organization)  
    @organization.create_reset_key_and_send_reset_notification 
    @params = { :key          => @organization.reset_password_key, 
                :organization => { :password => '123456', :password_confirmation => '123456' } } 
  end
  
  after(:each) do
    @organization.destroy
  end
  
  def do_put
    put :reset, @params
    @organization.reload
  end 
 
  it "should change the organization's password" do  
    lambda{ do_put }.should change(@organization,:crypted_password)
  end
   
  it "should delete the organization's session key" do  
    lambda{ do_put }.should change(@organization,:reset_password_key).to(nil)
  end
    
  it "should assign the organization to the view" do
    do_put
    assigns[:organization].should == @organization
  end   
 
  it "should redirect to the new session path" do  
    do_put
    response.should redirect_to(new_session_path)
  end
  
  it "should flash a success message" do  
    do_put
    flash[:notice].should_not be_blank
  end
  
  describe "when the organization is not found" do
  
    before(:each) do
      @params[:organization][:password] = '12'
    end
  
    it "should render the reset template" do
      do_put
      response.should render_template('reset')
    end
  
  end

end


describe AccountsController, " handling GET /account/deactivate" do

  before(:each) do
    @current_organization = Factory.create(:organization)
    @params = { :key => @current_organization.deactivation_key }
  end
  
  def do_get
    get :deactivate, @params
    @current_organization.reload
  end
  
  it "should redirect to the new session page" do    
    do_get
    response.should redirect_to(new_session_path)
  end
  
  it "should deactivate the organization" do  
    lambda{ do_get }.should change(@current_organization, :deactivated?).from(false).to(true)
  end
  
  it "should redirect to the login page if the organization is not found" do
    @params[:key] = '1234'
    do_get
    response.should redirect_to(new_session_path)
  end
  
  it "should notify the admin" do
    Notifier.should_receive(:deliver_report_account_deactivation).with(@current_organization)
    do_get
  end
  
  it "should not deactivate if the organization is already deactivated" do
    @current_organization.deactivate
    @current_organization.should_not_receive(:deactivate)
    do_get
  end
 
end
 

