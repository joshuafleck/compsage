require File.dirname(__FILE__) + '/../spec_helper'

describe SurveyInvitationsController, " #route for" do
  it "should map { :controller => 'invitations', :action => 'index', :survey_id => '1' } to /surveys/1/invitations" do
    route_for(:controller => "survey_invitations", :action => "index", :survey_id => '1').should == "/surveys/1/invitations"
  end

  it "should map { :controller => 'invitations', :action => 'new', :survey_id => '1' } to /surveys/1/invitations/new" do
    route_for(:controller => "survey_invitations", :action => "new", :survey_id => '1').should == "/surveys/1/invitations/new"
  end

  it "should map { :controller => 'invitations', :action => 'destroy', :id => '1', :survey_id => '1'} to /surveys/1/invitations/1" do
    route_for(:controller => "survey_invitations", :action => "destroy", :id => '1', :survey_id => '1').should == { :path => "/surveys/1/invitations/1", :method => :delete }
  end
  
  it "should map { :controller => 'invitations', :action => 'decline', :id => '1', :survey_id => '1'} to /surveys/1/invitations/1/decline" do
    route_for(:controller => "survey_invitations", :action => "decline", :id => '1', :survey_id => '1').should == { :path => "/surveys/1/invitations/1/decline", :method => :put }
  end    

  it "should map { :controller => 'invitations', :action => 'create_for_network', :survey_id => '1'} to /surveys/1/invitations/create_for_network" do
    route_for(:controller => "survey_invitations", :action => "create_for_network", :survey_id => '1').should == { :path => "/surveys/1/invitations/create_for_network", :method => :post }
  end 
end

describe SurveyInvitationsController, " handling GET /surveys/1/invitations" do

  before do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @invitation = mock_model(SurveyInvitation, :id => 1, :inviter => @current_organization)
    @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => @current_organization, :job_title => "test", :all_invitations => @invitations)
    @surveys_proxy = mock('surveys proxy')
    @surveys_proxy.stub!(:find).and_return(@survey)
    @network = mock_model(Network, :id => "1", :included= => "1")
    @networks = [@network]
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    @current_organization.stub!(:networks).and_return(@networks)
    
    @params = {:survey_id => 1}
  end
  
  def do_get
    get :index, @params
  end

  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render index template" do
    do_get
    response.should render_template('index')
  end
  
  it "should assign the found survey invitations for the view" do    
    do_get
    assigns(:invitations).should eql(@invitations)
  end
   
  it "should assign the networks for the view" do    
    do_get
    assigns(:networks).should eql(@networks)
  end   
   
  it "should find all invitations" do
    @survey.should_receive(:all_invitations).and_return(@invitations)
    do_get
  end
  
  it "should find all networks" do
    @current_organization.should_receive(:networks).and_return(@networks)
    do_get
  end  
      
  it "should error if requesting organization is not survey sponsor" do
    @current_organization.should_receive(:sponsored_surveys).and_return(@surveys_proxy)
    do_get
  end
   
end

describe SurveyInvitationsController, " handling POST /surveys/1/invitations" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    @survey = Factory(:survey, :sponsor => @current_organization)
    @current_organization.sponsored_surveys.stub!(:find).and_return(@survey)

    @params = {:survey_id => @survey.id, :organization_id => @current_organization.id}
  end
 
  def do_post
    post :create, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post
  end
   
  describe "when inviting an organization by id" do
    before do
      @other_organization = Factory(:organization)
      @params.merge!({:organization_id => @other_organization.id.to_s})
    end

    it "should find the organization to invite" do
      Organization.should_receive(:find).at_least(:once).and_return(@other_organization)
      do_post
    end

    it "should create an internal invitation to the survey" do
      @survey.invitations.should_receive(:new).and_return(Invitation.new)
      do_post
    end
  end
end

describe SurveyInvitationsController, " handling DELETE /surveys/1/invitations/1" do
  before do
    @current_organization = mock_model(Organization, :name => "test")
    login_as(@current_organization)
    
    @invitation = mock_model(SurveyInvitation, :id => 1, :inviter => @current_organization, :to_xml => 'XML', :destroy => true)
    @invitations_proxy = mock('invitations proxy')
    @invitations_proxy.stub!(:find).and_return(@invitation)
    
    @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => @current_organization, :job_title => "test", :internal_and_external_invitations => @invitations_proxy)
    @surveys_proxy = mock('surveys proxy')
    @surveys_proxy.stub!(:find).and_return(@survey)
    
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    @current_organization.stub!(:survey_invitations).and_return([])
    Organization.stub!(:find_by_email).and_return(@current_organization)
    
    @surveys_proxy.stub!(:running).and_return(@surveys_proxy)
    @invitations_proxy.stub!(:new).and_return(@invitation)
    
    @params = {:survey_id => 1, :id => @invitation.id}
  end
 
  def do_delete
    delete :destroy, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_delete
  end
  
  it "should only allow the sponsor to delete invitations" do
    @current_organization.should_receive(:sponsored_surveys).and_return(@surveys_proxy)
    do_delete
  end
   
  it "should find the invitation requested" do
    @invitations_proxy.should_receive(:find).and_return(@invitation)
    do_delete
  end
   
  it "should destroy the invitation requested" do
    @invitation.should_receive(:destroy).and_return(true)
    do_delete
  end
   
  it "should redirect to the invitation index page" do
    do_delete
    response.should redirect_to('/surveys/1/invitations')
  end
   
end

describe SurveyInvitationsController,  "handling PUT /surveys/1/invitations/1/decline" do
  before do
    @survey = Factory.create(:survey)    
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @invitation = mock_model(
      SurveyInvitation, 
      :survey => @survey, 
      :inviter => @survey.sponsor, 
      :invitee => @current_organization, 
      :id => "1",
      :decline! => true)
      
    @survey_invitations_proxy = mock('surveys proxy', :find => @invitation)
    
    @current_organization.stub!(:survey_invitations).and_return(@survey_invitations_proxy)
    
    @params = {:survey_id => @survey.id, :id => @invitation.id}
  end
  
  def do_put
    put :decline, @params
  end
  
  it "should be successful" do
        do_put
        response.should redirect_to(surveys_path)
  end  
  
  it "should change the status of the invitation to 'declined'" do
    @invitation.should_receive(:decline!)
    do_put
  end
  
end

describe SurveyInvitationsController, "sending pending invitations" do
  before do
    @organization = Factory(:organization)
    login_as(@organization)

    @survey = Factory(:survey, :sponsor => @organization)
    @pending_invitations = [Factory(:survey_invitation, :survey => @survey),
                            Factory(:external_survey_invitation, :survey => @survey)]
  end

  def do_post
    post :send_pending, :survey_id => @survey.id
  end
  
  it "should send the invitations" do
    do_post
    @pending_invitations.each do |invitation|
      invitation.reload
      invitation.should be_sent
    end
  end

  it "should redirect to the survey show page" do
    do_post
    response.should be_redirect
    response.should redirect_to(survey_path(@survey))
  end
end
