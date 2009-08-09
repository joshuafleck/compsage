require File.dirname(__FILE__) + '/../spec_helper'

describe SurveysController, "#route_for" do
  it "should map { :controller => 'surveys', :action => 'index' } to /surveys" do
    route_for(:controller => "surveys", :action => "index").should == "/surveys"
  end
  
  it "should map { :controller => 'surveys', :action => 'search' } to /search" do
    route_for(:controller => "surveys", :action => "index").should == "/surveys"
  end

  it "should map { :controller => 'surveys', :action => 'new' } to /surveys/new" do
    route_for(:controller => "surveys", :action => "new").should == "/surveys/new"
  end

  it "should map { :controller => 'surveys', :action => 'show', :id => '1' } to /surveys/1" do
    route_for(:controller => "surveys", :action => "show", :id => '1').should == "/surveys/1"
  end

  it "should map { :controller => 'surveys', :action => 'edit', :id => '1' } to /surveys/1/edit" do
    route_for(:controller => "surveys", :action => "edit", :id => '1').should == "/surveys/1/edit"
  end

  it "should map { :controller => 'surveys', :action => 'update', :id => '1'} to /surveys/1" do
    route_for(:controller => "surveys", :action => "update", :id => '1').should == {:path => "/surveys/1", :method => :put }
  end
  
  it "should map { :controller => 'surveys', :action => 'destroy', :id => '1'} to /surveys/1" do
    route_for(:controller => "surveys", :action => "destroy", :id => '1').should == {:path => "/surveys/1", :method => :delete }
  end  
  
  it "should map { :controller => 'surveys', :action => 'create' } to /surveys" do
    route_for(:controller => "surveys", :action => "create").should == {:path => "/surveys", :method => :post }
  end  
  
  it "should map { :controller => 'surveys', :action => 'respond', :id => '1'} to /surveys/1/respond" do
    route_for(:controller => "surveys", :action => "respond", :id => '1').should == {:path => "/surveys/1/respond", :method => :put }
  end
  
  it "should map { :controller => 'surveys', :action => 'reports' } to /surveys/reports" do
    route_for(:controller => "surveys", :action => "reports").should == "/surveys/reports"
  end 
  
  it "should map { :controller => 'surveys', :action => 'rerun', :id => '1' } to /surveys/1/rerun" do
    route_for(:controller => "surveys", :action => "rerun", :id => "1").should == {:path => "/surveys/1/rerun", :method => :put }
  end  
end

describe SurveysController, " handling GET /surveys" do
  before do
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)

    @running_survey = Factory(:running_survey)
  end
    
  def do_get
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index template" do
    do_get
    response.should render_template('index')
  end

  it "should assign all running surveys" do
    do_get
    assigns[:surveys].should_not be_nil
    assigns[:surveys].should include(@running_survey)
  end

  describe "finding invitations" do
    before do
      @sent_invitation      = Factory(:survey_invitation,
                                      :survey => Factory(:survey, :aasm_state => 'running'),
                                      :invitee => @current_organization,
                                      :aasm_state => 'sent')

      @pending_invitation   = Factory(:survey_invitation,
                                      :survey => Factory(:survey, :aasm_state => 'running'),
                                      :invitee => @current_organization)

      @declined_invitation  = Factory(:survey_invitation,
                                      :survey => Factory(:survey, :aasm_state => 'running'),
                                      :invitee => @current_organization,
                                      :aasm_state => 'declined')

      @fulfilled_invitation = Factory(:survey_invitation,
                                      :survey => Factory(:survey, :aasm_state => 'running'),
                                      :invitee => @current_organization,
                                      :aasm_state => 'fulfilled')
      
      @invitation_to_finished_survey = Factory(:survey_invitation,
                                               :survey => Factory(:survey, :aasm_state => 'finished'),
                                               :invitee => @current_organization,
                                               :aasm_state => 'sent')
    end

    it "should assign sent survey invitations" do
      do_get
      assigns[:invited_surveys].should_not be_nil
      assigns[:invited_surveys].should include(@sent_invitation)
    end

    it "should only assign survey invitations that are sent" do
      do_get
      assigns[:invited_surveys].should_not include(@pending_invitation)
      assigns[:invited_surveys].should_not include(@declined_invitation)
      assigns[:invited_surveys].should_not include(@fulfilled_invitation)
    end

    it "should not assign invitations to surveys that are finished" do
      do_get
      assigns[:invited_surveys].should_not include(@invitation_to_finished_survey)
    end
  end

  describe "finding my surveys" do
    before do
      @running_survey  = Factory(:running_survey, :sponsor => @current_organization)
      @pending_survey  = Factory(:pending_survey, :sponsor => @current_organization)
      @stalled_survey  = Factory(:stalled_survey, :sponsor => @current_organization)
      @finished_survey = Factory(:finished_survey, :sponsor => @current_organization)
    end

    it "should assign stalled sponsored surveys" do
      do_get
      assigns[:my_surveys].should include(@stalled_survey)
    end

    it "should assign running sponsored surveys" do
      do_get
      assigns[:my_surveys].should include(@running_survey)
    end

    it "should not assign finished sponsored surveys" do
      do_get
      assigns[:my_surveys].should_not include(@finished_survey)
    end

    it "should not assign pending sponsored surveys" do
      do_get
      assigns[:my_surveys].should_not include(@pending_survey)
    end
  end

  describe "finding survey participations" do
    before do
      @participation = Factory(:participation,
                               :survey => Factory(:running_survey),
                               :participant => @current_organization)

      @my_survey_participation   = Factory(:participation,
                                           :survey => Factory(:running_survey, :sponsor => @current_organization),
                                           :participant => @current_organization)

      @stalled_participation_new = Factory(:participation,
                                           :survey => Factory(:stalled_survey, :end_date => Time.now - 12.hours),
                                           :participant => @current_organization)

      @stalled_participation_old = Factory(:participation,
                                           :survey => Factory(:stalled_survey, :end_date => Time.now - 2.days),
                                           :participant => @current_organization)
    end

    it "should assign recent survey participations" do
      do_get
      assigns[:survey_participations].should include(@participation)
    end

    it "should not assign recent survey participations to sponsored surveys" do
      do_get
      assigns[:survey_participations].should_not include(@my_survey_participation)
    end

    it "should include stalled survey participations with end dates within 24 hours" do
      do_get
      assigns[:survey_participations].should include(@stalled_participation_new)
    end

    it "should not assign recent survey participations to surveys stalled over a day ago" do
      do_get
      assigns[:survey_participations].should_not include(@stalled_participation_old)
    end
  end

  it "should assign recent survey results for my surveys" do
    finished_survey = Factory(:survey, :sponsor => @current_organization, :aasm_state => 'finished')
    do_get
    assigns[:my_results].should include(finished_survey)
  end

  it "should assign recent survey results for surveys I've participated in" do
    finished_survey = Factory(:survey, :aasm_state => 'finished')
    participation   = Factory(:participation, :participant => @current_organization, :survey => finished_survey)

    do_get

    assigns[:my_results].should include(finished_survey)
  end
end

describe SurveysController, " handling GET /surveys/1" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)

    @survey = Factory(:running_survey)
  end
  
  def do_get
    get :show, :id => @survey.id
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should assign the survey to the view" do
    do_get
    assigns[:survey].should == @survey
  end

  describe "with a survey that isn't finished" do

    it "should render the running template" do
      do_get
      response.should render_template('surveys/show_running')
    end

    describe "when finding discussions" do
      before do
        @good_discussion_topic = Factory(:discussion, :survey => @survey)
        @good_discussion_reply = Factory(:discussion, :survey => @survey)
        @good_discussion_reply.move_to_child_of(@good_discussion_topic)
        @bad_discussion_topic  = Factory(:discussion, :survey => @survey, :times_reported => 1)
      end

      it "should find discussions that are within the abuse threshold" do
        do_get
        assigns[:discussions].should include(@good_discussion_topic)
      end

      it "should not find discussions that are beyond the abuse threshold" do
        do_get
        assigns[:discussions].should_not include(@bad_discussion_topic)
      end

      it "should only assign top level discussions" do
        do_get
        assigns[:discussions].should_not include(@good_discussion_reply)
      end

      it "should assign a new discussion to the view" do
        do_get
        assigns[:discussion].should_not be_nil
        assigns[:discussion].should be_new_record
      end
    end

    describe "when finding invitations" do
      before do
        @invitation         = Factory(:sent_survey_invitation, :survey => @survey)
        @pending_invitation = Factory(:pending_survey_invitation, :survey => @survey)
      end

      it "should find all the survey invitations" do
        do_get
        assigns[:invitations].should include(@invitation)
      end

      it "should find the survey invitations including the survey sponsor" do
        do_get
        assigns[:invitations].any?{|i| i.invitee == @survey.sponsor}.should be_true
      end

      it "should not assign pending invitations" do
        do_get
        assigns[:invitations].should_not include(@pending_invitation)
      end
    end

    it "should render the stalled template with a stalled survey" do
      @survey = Factory(:stalled_survey)
      do_get
      response.should render_template('surveys/show_stalled')
    end
  end

  describe "with a finished survey" do
    it "should redirect to the report page" do
      @survey = Factory(:finished_survey)
      do_get
      response.should be_redirect
      response.should redirect_to(survey_report_path(@survey))
    end
  end
end

describe SurveysController, " handling GET /surveys/new" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
  end

  def do_get
    get :new, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end  
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should assign a pending survey to the view" do
    do_get
    assigns[:survey].should_not be_nil
    assigns[:survey].should be_pending
  end  
  
  describe "when surveying a network" do
    it "should save the survey network id in the session" do
      @params = {:network_id => "1"}
      do_get
      session[:survey_network_id].should eql("1")
    end  
  end
    
  it "should render new template" do
    do_get
    response.should render_template('surveys/new')
  end
end


describe SurveysController, " handling GET /surveys/1/edit" do
  before do
    @current_organization = Factory(:organization) 
    login_as(@current_organization)

    @survey = Factory(:running_survey, :sponsor => @current_organization)
  end

  def do_get
    get :edit, :id => @survey.id
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render the edit template" do
    do_get
    response.should render_template('surveys/edit')
  end
  
  it "should assign the found survey to the view" do
    do_get
    assigns[:survey].should_not be_nil
    assigns[:survey].should == @survey
  end

  describe "with a survey with a participation" do
    before do
      @participation = Factory(:participation, :survey => @survey)
    end

    it "should redirect to the survey view" do
      do_get
      response.should be_redirect
      response.should redirect_to(survey_path(@survey))
    end

    it "should flash an error message" do
      do_get
      flash[:notice].should_not be_blank
    end
  end
end

describe SurveysController, "handling GET /surveys/1/edit when not the survey sponsor" do
  before do
    @current_organization = Factory(:organization) 
    login_as(@current_organization)

    @survey = Factory(:running_survey)
  end

  def do_get
    get :edit, :id => @survey.id
  end

  it "should raise a 404 error" do
    lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)
  end
end

describe SurveysController, " handling PUT /surveys/1" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:running_survey, :sponsor => @current_organization)

    @params = {:id => @survey.id, :survey => {:job_title => 'Updated'} }
  end
  
  def do_update
    put :update, @params
    @survey.reload
  end
  
  it "should update the selected survey" do
    do_update
    @survey.job_title.should == "Updated"
  end

  it "should assign the found survey to the view" do
    do_update
    assigns(:survey).should == @survey
  end
  
  it "should redirect to the survey preview page for this survey upon success" do
    do_update
    response.should redirect_to(preview_survey_questions_path(@survey))
  end    

  describe "with a validation error" do
    before do
      @params[:survey][:job_title] = ""
    end

    it "should render the edit template" do
      do_update
      response.should render_template('edit')
    end
  end
end
  
describe SurveysController, "handling PUT /surveys/1 with a pending survey" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:pending_survey, :sponsor => @current_organization)

    @params = {:id => @survey.id, :survey => {:job_title => 'Updated'} }
  end
  
  def do_update
    put :update, @params
    @survey.reload
  end

  it "should redirect to the survey invitations page for this survey upon success" do
    do_update
    response.should redirect_to(survey_invitations_path(@survey))
  end
end

describe SurveysController, " handling PUT /surveys/1 when the current organization isn't the sponsor" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:pending_survey)

    @params = {:id => @survey.id, :survey => {:job_title => 'Updated'} }
  end

  def do_update
    put :update, @params
  end

  it "should error if requesting organization is not the sponsor"  do
    lambda { do_update }.should raise_error(ActiveRecord::RecordNotFound)
  end
end

describe SurveysController, " handling PUT /surveys/1, with participations" do
  before do
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)
        
    @survey = Factory.create(:running_survey, :sponsor => @current_organization)
    Factory.create(:participation, :survey => @survey, :participant => @current_organization)
  end

  def do_update
    put :update, :id => @survey.id
  end
  
  it "should redirect to the survey show page" do
    do_update
    response.should redirect_to(survey_path(@survey))
  end
end

describe SurveysController, "handling GET /surveys/search" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @surveys = [Factory(:survey), Factory(:survey)]

    Survey.stub!(:search).and_return(@surveys)
    @params = {:search_text => "josh"}
  end
  
  def do_get
    get :search, @params
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render the search template" do
    do_get
    response.should render_template('search')
  end
  
  it "should search the users surveys" do	
    Survey.should_receive(:search).and_return(@surveys)
    do_get
  end
  
  it "should assign found surveys to the view" do
    do_get
    assigns[:surveys].should == @surveys
  end
end

describe SurveysController, "handling POST /surveys/1/respond, as invitee that is not a shawarma user" do
  before do
    @survey = Factory(:survey)
    @current_invitation = Factory(:sent_external_survey_invitation, :survey => @survey)
    login_as(@current_invitation)

    @participation = Factory.create(:participation, :survey => @survey, :participant => @current_invitation)
  end
  
  def do_respond
    post :respond, :id => @survey.id
  end
  
  it "should redirect to the success/sign-up page " do
    do_respond
    response.should redirect_to("/account/new")
  end
  
  it "should flash a success message" do
    do_respond
    flash[:notice].should eql("Thank you for participating in the survey!  You will be notified when results are available.")
  end
end

describe SurveysController, "handling POST /surveys/1/respond, as an organization" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)

    @survey = Factory(:survey)

    @participation = Factory.create(:participation, :survey => @survey, :participant => @current_organization)
  end
  
  def do_respond
    post :respond, :id => @survey.id
  end
  
  it "should redirect to the survey show page" do
    do_respond
    response.should redirect_to(survey_path(@survey))
  end
  
  it "should flash a success message" do
    do_respond
    flash[:notice].should eql("Thank you for participating in the survey!  You will be notified when results are available.")
  end
end

describe SurveysController, "handling POST /surveys/1/respond, with invalid respones" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)

    @survey = Factory(:survey)
  end
  
  def do_respond
    post :respond, :id => @survey.id
  end
  
  it "should re-render questions index" do 
    do_respond
    response.should render_template('questions/index')
  end
end

describe SurveysController, " handling GET /surveys/1/rerun" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)

    @survey = Factory(:stalled_survey, :sponsor => @current_organization)
  end

  def do_rerun
    get :rerun, :id => @survey.id
    @survey.reload
  end
  
  it "should be successful" do
    do_rerun
    response.should be_redirect
  end
  
  it "should rerun the survey" do
    do_rerun
    @survey.should be_running
  end
  
  it "should render the survey invitations page on success" do
    do_rerun
    response.should redirect_to(survey_invitations_path(@survey))
  end
end
  
describe SurveysController, " handling GET /surveys/1/rerun with error" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)

    @survey = Factory(:stalled_survey, :sponsor => @current_organization, :start_date => Time.now - 30.days)
  end

  def do_rerun
    get :rerun, :id => @survey
  end
  
  it "should render the survey page on failure" do
    do_rerun
    response.should redirect_to(survey_path(@survey))
  end
end

describe SurveysController, "handling GET /surveys/1/finish_partial" do
  before do
    @current_organization = Factory(:organization)
    login_as(@current_organization)

    @survey = Factory(:stalled_survey, :sponsor => @current_organization, :start_date => Time.now - 30.days)
    @invoice = Factory(:invoice, :survey => @survey)
  end

  def do_get
    get :finish_partial, :id => @survey.id
    @survey.reload
  end

  it "should redirect to the survey report path" do
    do_get
    response.should redirect_to(survey_report_path(@survey))
  end

  it "should finish the survey" do
    do_get
    @survey.should be_finished
  end
end
