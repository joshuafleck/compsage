require File.dirname(__FILE__) + '/../spec_helper'

describe SurveyInvitationsController, " #route for" do
  it "should map { :controller => 'invitations', :action => 'index', :survey_id => '1' } to /surveys/1/invitations" do
    route_for(:controller => "survey_invitations", :action => "index", :survey_id => '1').should == "/surveys/1/invitations"
  end

  it "should map { :controller => 'invitations', :action => 'destroy', :id => '1', :survey_id => '1'} to /surveys/1/invitations/1" do
    route_for(:controller => "survey_invitations", :action => "destroy", :id => '1', :survey_id => '1').should == { :path => "/surveys/1/invitations/1", :method => :delete }
  end

  it "should map { :controller => 'invitations', :action => 'create', :survey_id => '1'} to /surveys/1/invitations" do
    route_for(:controller => "survey_invitations", :action => "create", :survey_id => '1').should == { :path => "/surveys/1/invitations", :method => :post }
  end
    
  it "should map { :controller => 'invitations', :action => 'decline', :id => '1', :survey_id => '1'} to /surveys/1/invitations/1/decline" do
    route_for(:controller => "survey_invitations", :action => "decline", :id => '1', :survey_id => '1').should == { :path => "/surveys/1/invitations/1/decline", :method => :put }
  end    

  it "should map { :controller => 'invitations', :action => 'create_for_network', :survey_id => '1'} to /surveys/1/invitations/create_for_network" do
    route_for(:controller => "survey_invitations", :action => "create_for_network", :survey_id => '1').should == { :path => "/surveys/1/invitations/create_for_network", :method => :post }
  end 
  
  it "should map { :controller => 'invitations', :action => 'update_message', :survey_id => '1'} to /surveys/1/invitations/update_message" do
    route_for(:controller => "survey_invitations", :action => "update_message", :survey_id => '1').should == { :path => "/surveys/1/invitations/update_message", :method => :post }
  end   
end

describe SurveyInvitationsController, " handling GET /surveys/1/invitations" do

  before do
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)
    
    @survey = Factory.create(:survey, :sponsor => @current_organization)
    @network = Factory.create(:network, :owner => @current_organization)
    @member = Factory.create(:organization)
    @network.organizations << @member
    @sent_invitation = Factory.create(:sent_survey_invitation, :survey => @survey, :inviter => @current_organization)
    @pending_invitation = Factory.create(:pending_survey_invitation, :survey => @survey, :inviter => @current_organization)
    @external_invitation = Factory.create(:external_survey_invitation, :survey => @survey, :inviter => @current_organization)
    session[:survey_network_id] = @network.id

    @params = {:survey_id => @survey.id}
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
  
  it "should assign the sent invitations for the view" do    
    do_get
    assigns(:invitations).should include(@sent_invitation)
  end
   
  it "should assign the pending invitations for the view" do    
    do_get
    assigns(:invitations).should include(@pending_invitation)
  end
      
  it "should assign the external invitations for the view" do    
    do_get
    assigns(:invitations).should include(@external_invitation)
  end
       
  it "should assign the networks for the view" do    
    do_get
    assigns(:networks).size.should == 1
  end   
   
  it "should assign the survey for the view" do    
    do_get
    assigns(:survey).should == @survey
  end
  
  it "should invite the survey-network members to the survey" do
    lambda{ do_get }.should change(@member.survey_invitations,:count).by(1)
  end
   
  it "should not invite the survey sponsor to the survey" do
    lambda{ do_get }.should change(@current_organization.survey_invitations,:count).by(0)
  end
   
  it "should remove the survey-network from the session" do
    do_get
    session[:survey_network_id].should be_nil
  end
 
end

describe SurveyInvitationsController, " handling POST /surveys/1/invitations" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:survey, :sponsor => @current_organization)

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

    it "should create an internal invitation to the survey" do
      lambda{ do_post }.should change(@other_organization.survey_invitations,:count).by(1)
    end
  end
  
  describe "when inviting an organization by email" do
    before do
      @params.merge!(:external_invitation => {:organization_name => "josh inc", :email => "flec0026@umn.edu"})
      @params.delete(:organization_id)
    end

    it "should create an external invitation to the survey" do
      lambda{ do_post }.should change(@survey.external_invitations,:count).by(1)
    end
  end  
end

describe SurveyInvitationsController, " handling POST /surveys/1/invitations/create_for_network" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:survey, :sponsor => @current_organization)
    @network = Factory(:network, :owner => @current_organization)
    @member = Factory(:organization)
    @already_invited_member = Factory(:organization)
    
    Factory(:survey_invitation, :inviter => @current_organization, :invitee => @already_invited_member, :survey => @survey)
    @network.organizations << @member
    @network.organizations << @already_invited_member

    @params = {:survey_id => @survey.id, :network_id => @network.id}
  end
 
  def do_post
    post :create_for_network, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_post
  end
   
  it "should invite the network members" do
    lambda{ do_post }.should change(@member.survey_invitations,:count).by(1)
  end
    
  it "should not invite members already invited to the survey" do
    lambda{ do_post }.should change(@already_invited_member.survey_invitations,:count).by(0)
  end
     
  it "should not invite the survey sponsor" do
    lambda{ do_post }.should change(@current_organization.survey_invitations,:count).by(0)
  end
 
end

describe SurveyInvitationsController, " handling DELETE /surveys/1/invitations/1" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:survey, :sponsor => @current_organization)
    @invitation = Factory(:pending_survey_invitation, :survey => @survey, :inviter => @current_organization)
    
    @params = {:survey_id => @survey.id, :id => @invitation.id}
  end
 
  def do_delete
    delete :destroy, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_delete
  end
  
  it "should destroy the invitation requested" do
    lambda{ do_delete }.should change(@survey.invitations,:count).by(-1)
  end
  
  describe "with an external invitation" do
  
    it "should destroy the invitation requested" do
      @external_invitation = Factory(:external_survey_invitation, :survey => @survey, :inviter => @current_organization)
      @params[:id] = @external_invitation.id
      lambda{ do_delete }.should change(@survey.external_invitations,:count).by(-1)
    end
     
  end
      
end

describe SurveyInvitationsController,  "handling PUT /surveys/1/invitations/1/decline" do
  before do
  
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:running_survey)
    @invitation = Factory(:sent_survey_invitation, :survey => @survey, :invitee => @current_organization)
    
    @params = {:survey_id => @survey.id, :id => @invitation.id}
  end
  
  def do_put
    put :decline, @params
    @invitation.reload
  end
  
  it "should redirect to the survey index" do
    do_put
    response.should redirect_to(surveys_path)
  end  
  
  it "should change the status of the invitation to 'declined'" do
    lambda{ do_put }.should change(@invitation,:aasm_state).from('sent').to('declined')
  end
  
end

describe SurveyInvitationsController, "updating the invitation message and invitation list" do
  before do
    @organization = Factory(:organization)
    login_as(@organization)
  end

  def do_post
    post :update_message, :survey_id => @survey.id, :survey => {:custom_invitation_message => "new message"}
  end
  
  describe "with a pending survey" do
    before do
      @survey = Factory(:pending_survey, :sponsor => @organization)
      @pending_invitations = [Factory(:pending_survey_invitation, :survey => @survey),
                              Factory(:pending_external_survey_invitation, :survey => @survey)]
    end

    it "should update the invitation message" do
      do_post
      @survey.reload
      @survey.custom_invitation_message.should == "new message"
    end

    it "should not send any pending invitations" do
      do_post
      @pending_invitations.each do |invitation|
        invitation.reload
        invitation.should_not be_sent
      end
    end

    it "should redirect to the survey preview page" do
      do_post
      response.should be_redirect
      response.should redirect_to(preview_survey_questions_path(@survey))
    end
  end
  
  describe "with a running survey" do
    before do
      @survey = Factory(:running_survey, :sponsor => @organization)
      @pending_invitations = [Factory(:pending_survey_invitation, :survey => @survey),
                              Factory(:pending_external_survey_invitation, :survey => @survey)]
    end

    it "should update the invitation message" do
      do_post
      @survey.reload
      @survey.custom_invitation_message.should == "new message"
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
end
