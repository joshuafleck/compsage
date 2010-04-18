require File.dirname(__FILE__) + '/../spec_helper'

describe AssociationMembersController, "#route_for" do

  it "should map { :controller => 'association_members', :action => 'sign_in' } to /" do
    route_for(:controller => "association_members", :action => "sign_in").should == "/"
  end
  
  it "should map { :controller => 'association_members', :action => 'sign_in' } to /association_member/sign_in" do
    route_for(:controller => "association_members", :action => "sign_in").should == "/association_member/sign_in"
  end 
  
end  

describe AssociationMembersController, "handling GET /association_member/sign_in" do

  before(:each) do
  
    @association = Factory.create(:association)
    @login = "test@example.com"
    controller.stub!(:current_association).and_return(@association)
    
  end
  
  def do_get
    get :sign_in, :email => @login
  end
  
  it "should be successful" do    
    do_get
    response.should be_success
  end

  it "should require an association" do
    controller.stub!(:current_association).and_return(nil)
    do_get
    assert_response 404
  end
  
  it "should assign the login to the view" do
    do_get
    assigns[:login].should == @login
  end
  
end  

describe AssociationMembersController, "handling POST /association_member/sign_in" do

  before(:each) do
  
    @association                = Factory.create(:association)
    @uninitialized_organization = Factory.create(:uninitialized_association_member)
    @organization               = Factory.create(:organization)
    controller.stub!(:current_association).and_return(@association)
    
    @params = {}
  end
  
  after(:each) do
      @uninitialized_organization.destroy
      @association.destroy
      @organization.destroy
  end  
  
  def do_post
    post :sign_in, @params
     @uninitialized_organization.reload
  end

  it "should render the sign in page when the user is not an association member" do
    do_post
    response.should render_template('sign_in')
  end
  
  describe "when authenticating an initialized organization" do
    before(:each) do        
      @remember_me = "1"
      @association.organizations << @organization
      @params[:email] = @organization.email
      @params[:remember_me] = @remember_me
    end
  
    it "should render the sign in page when the authentication fails" do
      do_post
      response.should render_template('sign_in')
    end  
    
    it "should assign the 'remember me' flag to the view" do
      do_post
      assigns[:remember_me].should == @remember_me
    end
    
    it "logins and redirects" do
      @params[:password] = "test12"
      do_post
      session[:organization_id].should_not be_nil
      response.should be_redirect
    end    
    
  end
  
  describe "when authenticating an uninitialized association member" do
    before(:each) do    
      @association.organizations << @uninitialized_organization
      @params[:email] = @uninitialized_organization.email
      @params[:password] = "test12"
      @params[:password_confirmation] = @params[:password]
    end
        
    it "should unset the uninitialized flag on the association member" do
      lambda{ do_post }.should change(@uninitialized_organization, :uninitialized_association_member).to(false)
    end
   
    it "should send a new organization notification" do
      Notifier.should_receive(:deliver_new_organization_notification)
      do_post
    end   
    
    it "should accept the invitation when an invitation is present" do
      session[:invitation] = Factory(:external_network_invitation)
      lambda{ do_post }.should change(ExternalNetworkInvitation, :count).from(1).to(0)
    end   
    
    it "should accept the invitation when an invitation key is present" do
      @params[:key] = Factory(:external_network_invitation).key
      lambda{ do_post }.should change(ExternalNetworkInvitation, :count).from(1).to(0)
    end      
 
    it "should locate any external invitations by email and move them to the organization" do
      invitation_id = Factory(:external_survey_invitation, :email => @uninitialized_organization.email).id
      do_post
      invitation = Invitation.find(invitation_id)
      invitation.invitee.should == @uninitialized_organization
    end      
               
    it "should render the sign in page when login creation fails" do
      @params[:password_confirmation] = "qweqw"
      do_post
      response.should render_template('sign_in')
    end 
    
    it "should assign the association member to the view" do
      do_post
      assigns[:association_member].should == @uninitialized_organization
    end
    
    it "should log the user in" do
      do_post
      session[:organization_id].should_not be_nil
      response.should be_redirect
    end
    
    it "should display an error message when the user submits the 'returning firm' form" do
      @params[:submitted_returning_firm_form] = 'true'
      do_post
      response.should render_template('sign_in')
      # We can't spec flash.now
      # flash.now[:error].should == "Create a new password by filling in the 'First Time Logging In' section at the bottom right."
    end
        
   
  end  
    
end

