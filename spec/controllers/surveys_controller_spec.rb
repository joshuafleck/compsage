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

  it "should map { :controller => 'surveys', :action => 'show', :id => 1 } to /surveys/1" do
    route_for(:controller => "surveys", :action => "show", :id => 1).should == "/surveys/1"
  end

  it "should map { :controller => 'surveys', :action => 'edit', :id => 1 } to /surveys/1/edit" do
    route_for(:controller => "surveys", :action => "edit", :id => 1).should == "/surveys/1/edit"
  end

  it "should map { :controller => 'surveys', :action => 'update', :id => 1} to /surveys/1" do
    route_for(:controller => "surveys", :action => "update", :id => 1).should == "/surveys/1"
  end
  
  it "should map { :controller => 'surveys', :action => 'destroy', :id => 1} to /surveys/1" do
    route_for(:controller => "surveys", :action => "destroy", :id => 1).should == "/surveys/1"
  end  
  
  it "should map { :controller => 'surveys', :action => 'respond', :id => 1} to /surveys/1/respond" do
    route_for(:controller => "surveys", :action => "respond", :id => 1).should == "/surveys/1/respond"
  end
  
  it "should map { :controller => 'surveys', :action => 'reports' } to /surveys/reports" do
    route_for(:controller => "surveys", :action => "reports").should == "/surveys/reports"
  end 
  
  it "should map { :controller => 'surveys', :action => 'rerun' } to /surveys/1/rerun" do
    route_for(:controller => "surveys", :action => "rerun", :id => "1").should == "/surveys/1/rerun"
  end  
end

describe SurveysController, " handling GET /surveys" do
  
  before(:each) do
    @current_organization = Factory.create(:organization) #mock_model(Organization)
    login_as(@current_organization)
    
    @survey_invitations_proxy = mock('survey invitations proxy')

    @current_organization.stub!(:survey_invitations).and_return(@survey_invitations_proxy)

    @surveys = []
    @surveys.stub!(:paginate).and_return([])
    @surveys.stub!(:find).and_return([])
    Survey.stub!(:running).and_return(@surveys)
    @survey_invitations_proxy.stub!(:running).and_return(@surveys)
    @survey_invitations_proxy.stub!(:pending).and_return(@survey_invitations_proxy)
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
  
  it "should find all surveys for which the user has been invited or participated where the invitation is pending" do
    Survey.should_receive(:running).and_return(@surveys)
    @survey_invitations_proxy.should_receive(:running).and_return(@surveys)
    @survey_invitations_proxy.should_receive(:pending)
    @surveys.should_receive(:find)
    do_get 
  end
  
  it "should find all surveys for which the user has been the sponsor" do
    Survey.should_receive(:running).and_return(@surveys)
    @surveys.should_receive(:paginate).and_return([])
    
    do_get 
  end
  
  it "should assign the found surveys for the view" do
    do_get
    assigns[:invited_surveys].should_not be_nil
    assigns[:surveys].should_not be_nil
  end
end

describe SurveysController, " handling GET /surveys.xml" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @surveys = []
    @surveys.stub!(:to_xml).and_return("XML")
    Survey.stub!(:running).and_return(@surveys)   
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find all surveys for which the user has participated, been invited, or sponsored" do
    Survey.should_receive(:running).and_return(@surveys)
    do_get
  end
  it "should render the found surveys as XML" do
    @surveys.should_receive(:to_xml).and_return("XML")
    do_get
  end
end

describe SurveysController, " handling GET /surveys/1" do
  
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @survey = mock_model(Survey, :id => 1, :job_title => "test", :finished? => false, :all_invitations => [], :aasm_state => 'running') 
    Survey.stub!(:find).and_return(@survey)
        
    @discussion = mock_model(Discussion)
    @discussions = [@discussion]
    @discussions.stub!(:roots).and_return(@discussions)
    @discussions.stub!(:within_abuse_threshold).and_return(@discussions)
    @discussions.stub!(:new).and_return(@discussion)
    @survey.stub!(:discussions).and_return(@discussions)
    
    #participations stub
    @participations = []
    @participations = mock_model(Participation)
    @current_organization.stub!(:participations).and_return(@participations)
    @participations.stub!(:find_by_survey_id).and_return(@participation)
    
    
  end
  
  def do_get
    get :show, :id => 1
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the survey requested" do
    Survey.should_receive(:find).and_return(@survey)
    do_get
  end
  
  it "should render the running template" do
    do_get
    response.should render_template('surveys/show_running')
  end
  
  it "should assign the found survey to the view" do
    do_get
    assigns[:survey].should_not be_nil
  end
  
  it "should only retrieve discussions within the abuse threshold" do
    @discussions.should_receive(:within_abuse_threshold).and_return(@discussions)
    do_get
  end
  
  it "should find all root discussions" do
    @survey.should_receive(:discussions).and_return(@discussions)
    @discussions.should_receive(:roots).and_return(@discussion)
    do_get
  end
  
  it "should assign the found discussion for the view" do
    do_get
    assigns[:discussions].should eql(@discussions)
  end
  
end

describe SurveysController, " handling GET /surveys/1 when survey is closed" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @survey = mock_model(Survey, :id => 1, :discussions => nil, :job_title => "test", :all_invitations => [], :aasm_state => 'running') 
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:finished?).and_return(:true)
        
    @discussion = mock_model(Discussion)
    @discussions = [@discussion]
    @discussions.stub!(:within_abuse_threshold).and_return(@discussions)
    @discussions.stub!(:roots).and_return(@discussions)
    @discussions.stub!(:new).and_return(@discussion)
    @survey.stub!(:discussions).and_return(@discussions)
    
    #participations stub
    @participations = []
    @participations = mock_model(Participation)
    @current_organization.stub!(:participations).and_return(@participations)
    @participations.stub!(:find_by_survey_id).and_return(@participation)
    
  end

  it "should redirect to the report for the selected survey" do
    get :show, :id => 1
    response.should redirect_to(survey_report_path(@survey))
  end
end

describe SurveysController, " handling GET /surveys/1.xml" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @survey = mock_model(Survey, :id => 1, :job_title => "test", :all_invitations => [])    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:finished?).and_return(:false)
    @survey.stub!(:to_xml).and_return("XML")
        
    @discussion = mock_model(Discussion)
    @discussions = [@discussion]
    @discussions.stub!(:within_abuse_threshold).and_return(@discussions)
    @discussions.stub!(:roots).and_return(@discussions)
    @discussions.stub!(:new).and_return(@discussion)
    @survey.stub!(:discussions).and_return(@discussions)
    
    #participations stub
    @participations = []
    @participations = mock_model(Participation)
    @current_organization.stub!(:participations).and_return(@participations)
    @participations.stub!(:find_by_survey_id).and_return(@participation)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :show, :id => 1
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  it "should find the survey requested" do
    Survey.should_receive(:find).and_return(@survey)
    do_get
  end
  it "should render the found survey as XML" do
    @survey.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
end

describe SurveysController, " handling GET /surveys/1.xml when survey is closed" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @survey = mock_model(Survey, :id => 1, :job_title => "test", :all_invitations => [])    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:finished?).and_return(:true)
    
    @survey.stub!(:to_xml).and_return("XML")
        
    @discussion = mock_model(Discussion)
    @discussions = [@discussion]
    @discussions.stub!(:within_abuse_threshold).and_return(@discussions)
    @discussions.stub!(:roots).and_return(@discussions)
    @discussions.stub!(:new).and_return(@discussion)
    @survey.stub!(:discussions).and_return(@discussions)
    
    #participations stub
    @participations = []
    @participations = mock_model(Participation)
    @current_organization.stub!(:participations).and_return(@participations)
    @participations.stub!(:find_by_survey_id).and_return(@participation)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :show, :id => 1
  end

  it "should still show selected survey in XML" do
    do_get
    response.body.should == "XML"
  end
end

describe SurveysController, " handling GET /surveys/new with no pending surveys" do
  before(:each) do
    @surveys = []
    @surveys.stub!(:find_or_initialize_by_aasm_state).and_return([])
    @current_organization = mock_model(Organization, :sponsored_surveys => @surveys, :surveys => @surveys)
    login_as(@current_organization)
    @params = {:network_id => "1"}
  end

  def do_get
    get :new, @params
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should save the survey network id in the session" do
    do_get
    session[:survey_network_id].should eql("1")
  end  
    
  it "should render new template" do
    do_get
    response.should render_template('surveys/new')
  end
end

describe SurveysController, " handling GET /surveys/new with a pending survey" do
  before(:each) do
    @surveys = []
    @survey = mock_model(Survey, :id => 1)
    @surveys.stub!(:find_or_initialize_by_aasm_state).and_return([@survey])
    @current_organization = mock_model(Organization, :sponsored_surveys => @surveys, :surveys => @surveys)
    login_as(@current_organization)
  end

  def do_get
    get :new
  end

    
  it "should render new template" do
    do_get
    response.should render_template('surveys/new')
  end
end


describe SurveysController, " handling GET /surveys/1/edit" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @survey = mock_model(Survey, :id => 1, :sponsor => @current_organization, :job_title => "Slave")

    @question = mock_model(Question, :predefined_question_id => 1, :custom_question_type => "Free Response", :included= => "1")
    @predefined_question = mock_model(PredefinedQuestion, :id => 1, :included= => "1")
    @surveys_proxy = mock('surveys proxy')
    @open_surveys = []
    @predefined_questions = [@predefined_question]
    @questions = [@question]

    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    @surveys_proxy.stub!(:running_or_pending).and_return(@open_surveys)
    @open_surveys.stub!(:find).and_return(@survey)
    PredefinedQuestion.stub!(:all).and_return(@predefined_questions)
    @survey.stub!(:questions).and_return(@questions)
  end

  def do_get
    get :edit, :id => 1
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render the edit template" do
    do_get
    response.should render_template('surveys/edit')
  end
  
  it "should find the survey requested" do
    @current_organization.should_receive(:sponsored_surveys).and_return(@surveys_proxy)
    @surveys_proxy.should_receive(:running_or_pending).and_return(@open_surveys)
    @open_surveys.should_receive(:find).and_return(@survey)
    do_get
  end
  
  it "should assign the found survey, custom questions, and predefined questions to the view" do
    do_get
    assigns[:survey].should_not be_nil
  end
end

describe SurveysController, " handling GET /surveys/1/edit, without access" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @survey = mock_model(Survey, :id => 1, :sponsor => mock_model(Organization), :job_title => "test")
    @surveys_proxy = mock('surveys proxy')
    @open_surveys = []

    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    @surveys_proxy.stub!(:running_or_pending).and_return(@open_surveys)
    @open_surveys.stub!(:find).and_raise(ActiveRecord::RecordNotFound)
  end

  def do_get
    get :edit, :id => 1
  end
  it "should error if requesting organization is not the sponsor" do
    lambda{ do_get }.should raise_error(ActiveRecord::RecordNotFound)
  end
end

describe SurveysController, " handling POST /surveys" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    @params = {
                :survey => {
                   :job_title => 'That guy who yells "Scalpel, STAT!"',
                   :end_date => Time.now + 1.week
                 },
                 :predefined_questions => {
                    "1" => {'included' => "1"}, 
                    "2" => {'included' => "0"}, 
                    "3" => {'included' => "1"}
                 },
                 :questions => {
                    "1" => {'included' => "1", 'text' => 'question_1', 'custom_question_type' => 'Free Response'}, 
                    "2" => {'included' => "0", 'text' => 'question_2', 'custom_question_type' => 'Yes/No'}
                 }
               }
    @survey = mock_model(Survey, :id => 1, :billing_info_received! => true, :save => true, :errors => [], :new_record? => true, :job_title => "test", :invite_network => true)
    @surveys = []
    @questions_proxy = mock('questions_proxy')
    @question_hash = [{'id' => 1, 'another' => 2, 'text' => 'asdf'}, {'id' => 2, 'another' => 2, 'text' => 'asdf'}]
    @excluded_question_hash = {'another' => 2, 'text' => 'asdf'}
    @pdq1 = mock_model(
      PredefinedQuestion, 
      :id => 1, 
      :question_hash => @question_hash, 
      :included= => "1", 
      :included => "1", 
      :build_questions => [])
    @pdq2 = mock_model(PredefinedQuestion, :id => 2, :question_hash => @question_hash, :included= => "0", :included => "0")
    @pdq3 = mock_model(PredefinedQuestion, :id => 3, :question_hash => @question_hash, :included= => "1", :included => "1")
    @question = mock_model(
      Question, 
      :save! => true, 
      :predefined_question_id= => 1, 
      :survey= => @survey, 
      :included => "1", 
      :[]= => true,
      :move_to_bottom => true)
    
    PredefinedQuestion.stub!(:find).and_return(@pdq1)
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys)
    @surveys.stub!(:find_or_create_by_aasm_state).and_return(@survey)
    @survey.stub!(:questions).and_return(@questions_proxy)
    @survey.stub!(:update_attributes).and_return(:true)
    @questions_proxy.stub!(:build).and_return(@question)
    @questions_proxy.stub!(:find_all_by_predefined_question_id).and_return([])
  end
  
  def do_post
    post :create, @params
  end

  it "should create a new survey" do
    @surveys.should_receive(:find_or_create_by_aasm_state).and_return(@survey)
    do_post
  end
  
  it "should build any included custom questions" do
    @questions_proxy.should_receive(:build).with(@params[:questions]["1"])
    do_post
  end
  
  it "should build any included predefined questions" do
    PredefinedQuestion.should_receive(:find).with("1")
    @pdq1.should_receive(:build_questions).with(@survey)
    do_post
  end  
  
  it "should redirect to the survey preview page upon success" do
    do_post
    response.should redirect_to(preview_survey_questions_path(@survey))
  end
  
  it "should assign the questions and predefined questions to the view" do
    do_post
    assigns[:survey].should_not be_nil
  end
  
end

describe SurveysController, " handling POST /surveys from a 'survey network' link" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    @params = {:survey => {:job_title => 'That guy who yells "Scalpel, STAT!"' ,
                 :end_date => Time.now + 1.week
                 },
               :predefined_question => {"1" => {'included' => "1"}, "2" => {'included' => "0"}, "3" => {'included' => "1"}}, :invite_network => "1",
               :question => '[]'
               }
    @survey = mock_model(Survey, :id => 1, :save => true, :errors => [], :new_record? => true, :job_title => "test")
    @surveys = []
    @questions = []
    @question_hash = [{'id' => 1, 'another' => 2, 'text' => 'asdf'}, {'id' => 2, 'another' => 2, 'text' => 'asdf'}]
    @excluded_question_hash = {'another' => 2, 'text' => 'asdf'}
    @pdq1 = mock_model(PredefinedQuestion, :id => 1, :question_hash => @question_hash, :included= => "1", :included => 1)
    @pdq2 = mock_model(PredefinedQuestion, :id => 2, :question_hash => @question_hash, :included= => "1", :included => 0)
    @pdq3 = mock_model(PredefinedQuestion, :id => 3, :question_hash => @question_hash, :included= => "1", :included => 0)
    @question = mock_model(Question, :save! => :true, :predefined_question_id= => 1, :survey= => @survey, :included => 1)
    
    PredefinedQuestion.stub!(:all).and_return([@pdq1, @pdq2, @pdq3])
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys)
    @surveys.stub!(:new).and_return(@survey)
    @survey.stub!(:questions).and_return(@questions)
    @questions.stub!(:new).and_return(@question)
  end
  
  def do_post
    post :create, @params
  end

  it "should create the invitation upon success" do
    pending
  end
  
end

describe SurveysController, " handling POST /surveys, upon failure" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    @params = {:job_title => 'That guy who yells "Scalpel, STAT!"' ,
               :end_date => Time.now + 1.week ,
               :sponsor => mock_model(Organization),
               :question =>  {
                    "1" => {'included' => "1", 'text' => 'question_1', 'custom_question_type' => 'Free Response'}, 
                    "2" => {'included' => "0", 'text' => 'question_2', 'custom_question_type' => 'Yes/No'}
                 }}
    @survey = mock_model(Survey, :id => 1, :update_attributes => false, :errors => ["asdfadsfdsa"], :job_title => "test")
    @surveys = []
    @questions = []
    @question = mock_model(Question, :save! => :true, :predefined_question_id= => 1, :survey= => @survey, :included => "1", :[]= => true)
    
    @survey.stub!(:new_record?).and_return(true)
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys)
    @surveys.stub!(:find_or_create_by_aasm_state).and_return(@survey)
    @survey.stub!(:questions).and_return(@questions)
    @questions.stub!(:new).and_return(@question)
  end
  
  def do_post
    post :create, :survey => @params
  end
  
   it "should return to new page" do
     do_post
     response.should render_template('surveys/new')
   end
   
end

describe SurveysController, " handling PUT /surveys/1" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @survey = mock_model(Survey, :id => 1, :update_attributes => true, :sponsor => @current_organization, :job_title => "test")
    @surveys_proxy = mock('surveys proxy')
    @open_surveys = []
    @question_hash = [{'id' => 1, 'another' => 2, 'text' => 'asdf'}, {'id' => 2, 'another' => 2, 'text' => 'asdf'}]
    @excluded_question_hash = {'another' => 2, 'text' => 'asdf'}
    @pdq1 = mock_model(PredefinedQuestion, :id => 1, :question_hash => @question_hash)
    @pdq2 = mock_model(PredefinedQuestion, :id => 2, :question_hash => @question_hash)
    
    @params = {
                :predefined_questions => {
                  "1" => {'included' => "1"}, 
                  "2" => {'included' => "0"}, 
                  "3" => {'included' => "1"}},
                :id => 1,
                :questions =>  {
                    "1" => {'included' => "1", 'text' => 'question_1', 'custom_question_type' => 'Free Response', :id => 1}, 
                    "2" => {'included' => "0", 'text' => 'question_2', 'custom_question_type' => 'Yes/No', :id => 2}, 
                    "3" => {'included' => "1", 'text' => 'question_3', 'custom_question_type' => 'Yes/No'}
                 }
              }
    @questions_proxy = mock('questions proxy')
    @question = mock_model(Question, :attributes= =>"", 
                                     :predefined_question_id= => 1,
                                     :save! => true,
                                     :destroy => true,
                                     :nil? => false, 
                                     :[]= => true,
                                     :included => "1",
                                     :move_to_bottom => true)
    
    @pdq3 = mock_model(PredefinedQuestion, :id => 3, :question_hash => @question_hash, :build_questions => [@question])
    PredefinedQuestion.stub!(:find).with("1").and_return(@pdq1)
    PredefinedQuestion.stub!(:find).with("2").and_return(@pdq2)
    PredefinedQuestion.stub!(:find).with("3").and_return(@pdq3)
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    @surveys_proxy.stub!(:running).and_return(@open_surveys)
    @open_surveys.stub!(:find).and_return(@survey)
    @survey.stub!(:questions).and_return(@questions_proxy)
    @questions_proxy.stub!(:find_by_id).and_return(@question)
    @predefined_questions = [@question]
    @questions_proxy.stub!(:find_all_by_predefined_question_id).with("1").and_return(@predefined_questions)
    @questions_proxy.stub!(:find_all_by_predefined_question_id).with("2").and_return(@predefined_questions)
    @questions_proxy.stub!(:find_all_by_predefined_question_id).with("3").and_return([])
    @questions_proxy.stub!(:build).and_return(@question)
  end
  
  def do_update
    put :update, @params
  end
  
  it "should find the survey requested" do
    @current_organization.should_receive(:sponsored_surveys).and_return(@surveys_proxy)
    @surveys_proxy.should_receive(:running).and_return(@open_surveys)
    @open_surveys.should_receive(:find).and_return(@survey)
    do_update
  end
  
  it "should update the selected survey" do
    @survey.should_receive(:update_attributes).and_return(true)
    do_update
    assigns(:survey).should equal(@survey)
  end

  it "should check to see if the questions already exist" do
    @question.should_receive(:nil?)
    do_update
  end   
     
  it "should destroy any unselected questions that exist" do
    @question.should_receive(:destroy)
    do_update
  end  
  
  it "should create any selected questions that do not exist" do
    @questions_proxy.should_receive(:build).with(@params[:questions]["3"])
    do_update
  end 
  
  it "should check to see if the predefined questions already exist" do
    @predefined_questions.should_receive(:size).at_least(:once)
    do_update
  end   
     
  it "should destroy any unselected predefined questions that exist" do
    @question.should_receive(:destroy)
    do_update
  end  
  
  it "should create any selected predefined questions that do not exist" do
    PredefinedQuestion.should_receive(:find).with("3")
    @pdq3.should_receive(:build_questions).with(@survey)
    do_update
  end   

  it "should assign the found survey to the view" do
    do_update
    assigns(:survey).should equal(@survey)
  end
  
  it "should redirect to the survey preview page for this survey upon success" do
    do_update
    response.should redirect_to(preview_survey_questions_path(@survey))
  end
end
  
  describe SurveysController, " handling PUT /surveys/1, with failure" do
    before(:each) do
      @current_organization = mock_model(Organization)
      login_as(@current_organization)

      @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => @current_organization, :job_title => "test", :questions => [])
      @surveys_proxy = mock('surveys proxy')
      @open_surveys = []
      @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
      @surveys_proxy.stub!(:running).and_return(@open_surveys)
      @open_surveys.stub!(:find).and_return(@survey)
    end

    def do_update
      put :update, :id => @survey
    end
    
    it "should render edit template upon failure" do
      do_update
      response.should render_template('edit')
    end
  end

describe SurveysController, " handling PUT /surveys/1, with failure" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)

    @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => mock_model(Organization), :job_title => "test")
    @surveys_proxy = mock('surveys proxy')
    @open_surveys = []
    
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    @surveys_proxy.stub!(:running).and_return(@open_surveys)
    @open_surveys.stub!(:find).and_raise(ActiveRecord::RecordNotFound)
  end

  def do_update
    put :update, :id => 1
  end
  it "should error if requesting organization is not the sponsor"  do
    lambda{ do_update }.should raise_error(ActiveRecord::RecordNotFound)
  end
end

describe SurveysController, "handling GET /surveys/search" do
  before(:each) do
    @current_organization = mock_model(Organization, :industry => 'Fun', :latitude => 12, :longitude => 12)
    login_as(@current_organization)
    
    @survey = mock_model(Survey, :id => 1, :title => "My Survey")
    @surveys = [@survey]
    
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
    assigns[:surveys].should eql(@surveys)
  end
end
#NOTE: Test spec to move to factory_girl
describe SurveysController, "handling GET /surveys/search.xml" do
  before(:each) do
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)
        
    @survey = Factory.create(:survey)
    @surveys = [@survey]    

    Survey.stub!(:search).and_return(@surveys)        
    @params = {:search_text => "josh"}
    
  end
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :search, @params
  end
  
  it "should be successful" do
  	do_get
  	response.should be_success
  end
  
  it "should search the users surveys" do
  	Survey.should_receive(:search).and_return(@surveys)
    do_get
  end

  it "should render the found surveys in XML" do
    do_get
    response.body.should == @surveys.to_xml
  end
end

describe SurveysController, "handling POST /surveys/1/respond, as invitee that is not a shawarma user" do
  before(:each) do
    @survey = mock_model(Survey, :id => 1)
    @current_invitation = mock_model(SurveyInvitation, :survey => @survey)
    login_as(@current_invitation)
    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:questions).and_return([])
    
    #participations stub
    @participations = []
    @participation = Factory.create(:participation)
    @current_invitation.stub!(:participations).and_return(@participations)
    @participations.stub!(:find_or_initialize_by_survey_id).and_return(@participation)
  end
  
  def do_respond
    post :respond, :id => 1
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

describe SurveysController, "handling POST /surveys/1/respond, as organization based user" do
  before(:each) do
    @survey = mock_model(Survey, :id => 1)
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:questions).and_return([])
    
    #participations stub
    @participations = []
    @participation = Factory.create(:participation)
    @current_organization.stub!(:participations).and_return(@participations)
    @participations.stub!(:find_or_initialize_by_survey_id).and_return(@participation)
  end
  
  def do_respond
    post :respond, :id => 1
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
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    @q1 = mock_model(Question, :id => 1, :attributes => "", :numerical_response? => false, :question_type => "text_field")
    @q2 = mock_model(Question, :id => 2, :attributes => "", :numerical_response? => false, :question_type => "text_field")
    @questions = [@q1, @q2]
    @survey = mock_model(Survey, :id => 1)
    @survey.stub!(:questions).and_return(@questions)
    @responses = []

    @my_response = mock_model(Response, :update_attributes => true, :valid? => false, :textual_response => "", :textual_response= => true, :save => false, :question => mock_model(Question))
    @params = {:id => 1,
      :responses => {"1" => {:response => @my_response}, "2" => {:response => @my_response}}
    }
    
    Survey.stub!(:find).and_return(@survey)
    @responses.stub!(:find_or_create_by_question_id).and_return(@my_response)
    
    #participations stub
    @participations = []
    @errors = []
    @participation = mock_model(Participation, :responses => @responses, :attributes= => [], :save => false, :errors => @errors)
    @current_organization.stub!(:participations).and_return(@participations)
    @errors.stub!(:clear).and_return([])
    @participations.stub!(:find_or_initialize_by_survey_id).and_return(@participation)
  end
  
  def do_respond
    post :respond, @params
  end
  
  it "should re-render questions index" do 
    do_respond
    response.should render_template('questions/index')
  end
end

describe SurveysController, " handling GET /surveys/my.xml" do
  #pending
end

 describe SurveysController, " handling GET /surveys/1/rerun" do
    before(:each) do
      @current_organization = mock_model(Organization)
      login_as(@current_organization)

      @survey = mock_model(Survey, :id => 1, :update_attributes => true, :sponsor => @current_organization, :job_title => "test", :rerun! => true)
      @surveys_proxy = mock('surveys proxy')
      @stalled_surveys = mock('stalled surveys', :find => @survey)
      @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
      @surveys_proxy.stub!(:stalled).and_return(@stalled_surveys)
    end

    def do_rerun
      get :rerun, :id => @survey
    end
    
    it "should be successful" do
      do_rerun
      response.should be_redirect
    end
    
    it "should be update the end date" do
      @survey.should_receive(:update_attributes).and_return(true)
      do_rerun
    end
    
    it "should rerun the survey" do
      @survey.should_receive(:rerun!).and_return(true)
      do_rerun
    end
    
    it "should render the survey invitations page on success" do
      do_rerun
      response.should redirect_to(survey_invitations_path(@survey))
    end
  end
  
 describe SurveysController, " handling GET /surveys/1/rerun with error" do
    before(:each) do
      @current_organization = mock_model(Organization)
      login_as(@current_organization)

      @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => @current_organization, :job_title => "test", :rerun! => true)
      @surveys_proxy = mock('surveys proxy')
      @stalled_surveys = mock('stalled surveys', :find => @survey)
      @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
      @surveys_proxy.stub!(:stalled).and_return(@stalled_surveys)
    end

    def do_rerun
      get :rerun, :id => @survey
    end
    
    it "should render the survey page on failure" do
      do_rerun
      response.should redirect_to(survey_path(@survey))
    end
  end
  



