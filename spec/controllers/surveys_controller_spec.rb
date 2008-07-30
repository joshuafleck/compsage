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
  
  it "should map { :controller => 'surveys', :action => 'respond', :id => 1} to /surveys/1/respond" do
    route_for(:controller => "surveys", :action => "respond", :id => 1).should == "/surveys/1/respond"
  end
  
  it "should map { :controller => 'surveys', :action => 'my' } to /surveys/my" do
    route_for(:controller => "surveys", :action => "my").should == "/surveys/my"
  end  
end

describe SurveysController, " handling GET /surveys" do
  
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @survey_invitations_proxy = mock('survey invitations proxy')
    @survey_invitations_proxy.stub!(:find).and_return([])
    @current_organization.stub!(:survey_invitations).and_return(@survey_invitations_proxy)

    @surveys = []
    Survey.stub!(:running).and_return(@surveys)
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
  
  it "should find all surveys for which the user has been invited or participated" do
    @survey_invitations_proxy.should_receive(:find).with(:all, :include => :survey).and_return([])
    
    do_get 
  end
  
  it "should find all surveys for which the user has been the sponsor" do
    Survey.should_receive(:running).and_return(@surveys)
    
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
    
    @survey = mock_model(Survey, :id => 1, :job_title => "test")    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:closed?).and_return(:false)
        
    @discussion = mock_model(Discussion)
    @discussions = [@discussion]
    @discussions.stub!(:roots).and_return(@discussions)
    @discussions.stub!(:within_abuse_threshold).and_return(@discussions)
    @survey.stub!(:discussions).and_return(@discussions)
    
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
  it "should render the show template" do
    do_get
    response.should render_template('surveys/show')
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
  
  it "should assign the found discussion for the view"do
    do_get
    assigns[:discussions].should eql(@discussions)
  end
  
end

describe SurveysController, " handling GET /surveys/1 when survey is closed" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @survey = mock_model(Survey, :id => 1, :discussions => nil, :job_title => "test")    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:closed?).and_return(:true)
        
    @discussion = mock_model(Discussion)
    @discussions = [@discussion]
    @discussions.stub!(:within_abuse_threshold).and_return(@discussions)
    @discussions.stub!(:roots).and_return(@discussions)
    @survey.stub!(:discussions).and_return(@discussions)
    
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
    
    @survey = mock_model(Survey, :id => 1, :job_title => "test")    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:closed?).and_return(:false)
    @survey.stub!(:to_xml).and_return("XML")
        
    @discussion = mock_model(Discussion)
    @discussions = [@discussion]
    @discussions.stub!(:within_abuse_threshold).and_return(@discussions)
    @discussions.stub!(:roots).and_return(@discussions)
    @survey.stub!(:discussions).and_return(@discussions)
    
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
    
    @survey = mock_model(Survey, :id => 1, :job_title => "test")    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:closed?).and_return(:true)
    
    @survey.stub!(:to_xml).and_return("XML")
        
    @discussion = mock_model(Discussion)
    @discussions = [@discussion]
    @discussions.stub!(:within_abuse_threshold).and_return(@discussions)
    @discussions.stub!(:roots).and_return(@discussions)
    @survey.stub!(:discussions).and_return(@discussions)
    
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

describe SurveysController, " handling GET /surveys/new" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
  end

  def do_get
    get :new
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find a list of predefined questions" do
    PredefinedQuestion.should_receive(:all)
    do_get
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

    @surveys_proxy = mock('surveys proxy')
    @open_surveys = []
    @predefined_questions = []
    @questions = []

    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    @surveys_proxy.stub!(:running).and_return(@open_surveys)
    @open_surveys.stub!(:find).and_return(@survey)
    PredefinedQuestion.stub!(:all).and_return(@predefined_questions)
    @predefined_questions.stub!(:question_hash).and_return([])
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
    @surveys_proxy.should_receive(:running).and_return(@open_surveys)
    @open_surveys.should_receive(:find).and_return(@survey)
    do_get
  end
  
  it "should find predefined questions for the survey" do
    PredefinedQuestion.should_receive(:all).and_return(@predefined_questions)
    do_get
  end
  it "should determine if the predefined questions are chosen" do
    @predefined_questions.should_receive(:each)
    do_get
  end
  
  it "should assign the found survey, and predefined questions to the view" do
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
    @surveys_proxy.stub!(:running).and_return(@open_surveys)
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
    @params = {:survey => {:job_title => 'That guy who yells "Scalpel, STAT!"' ,
                 :end_date => Time.now + 1.week
                 },
               :predefined_question => {"1" => {'included' => "1"}, "2" => {'included' => "0"}, "3" => {'included' => "1"}}
               }
    @survey = mock_model(Survey, :id => 1, :save => true, :errors => [], :new_record? => true, :job_title => "test")
    @surveys = []
    @questions = []
    @question_hash = [{'id' => 1, 'another' => 2, 'text' => 'asdf'}, {'id' => 2, 'another' => 2, 'text' => 'asdf'}]
    @excluded_question_hash = {'another' => 2, 'text' => 'asdf'}
    @pdq1 = mock_model(PredefinedQuestion, :id => 1, :question_hash => @question_hash)
    @pdq2 = mock_model(PredefinedQuestion, :id => 2, :question_hash => @question_hash)
    @pdq3 = mock_model(PredefinedQuestion, :id => 3, :question_hash => @question_hash)
    @question = mock_model(Question, :save => :true, :predefined_question_id= => 1, :survey= => @survey)
    
    PredefinedQuestion.stub!(:all).and_return([@pdq1, @pdq2, @pdq3])
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys)
    @surveys.stub!(:new).and_return(@survey)
    @survey.stub!(:questions).and_return(@questions)
    @questions.stub!(:new).and_return(@question)
  end
  
  def do_post
    post :create, @params
  end

  it "should create a new survey" do
    @surveys.should_receive(:new).and_return(@survey)
    do_post
  end
  
  it "should add predefined questions to the survey" do
    @questions.should_receive(:new).at_least(:once).and_return(@question)
    @question.should_receive(:save).at_least(:twice).and_return(true)
    
    do_post
  end
  
  it "should redirect to the invitation show page upon success" do
    do_post
    response.should redirect_to(survey_invitations_url(@survey))
  end
  
end

describe SurveysController, " handling POST /surveys, upon failure" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    @params = {:job_title => 'That guy who yells "Scalpel, STAT!"' ,
               :end_date => Time.now + 1.week ,
               :sponsor => mock_model(Organization)}
    @survey = mock_model(Survey, :id => 1, :save => false, :errors => ["asdfadsfdsa"], :job_title => "test")
    @surveys = []
    
    @survey.stub!(:new_record?).and_return(true)
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys)
    @surveys.stub!(:new).and_return(@survey)
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
    
    @survey = mock_model(Survey, :id => "1", :update_attributes => true, :sponsor => @current_organization, :job_title => "test")
    @surveys_proxy = mock('surveys proxy')
    @open_surveys = []
    @question_hash = [{'id' => 1, 'another' => 2, 'text' => 'asdf'}, {'id' => 2, 'another' => 2, 'text' => 'asdf'}]
    @excluded_question_hash = {'another' => 2, 'text' => 'asdf'}
    @pdq1 = mock_model(PredefinedQuestion, :id => 1, :question_hash => @question_hash)
    @pdq2 = mock_model(PredefinedQuestion, :id => 2, :question_hash => @question_hash)
    @pdq3 = mock_model(PredefinedQuestion, :id => 3, :question_hash => @question_hash)
    
    @params = {:predefined_question => {"1" => {'included' => "1"}, "2" => {'included' => "0"}, "3" => {'included' => "1"}},
               :id => 1}
    @questions = []
    @question = mock_model(Question, :attributes= =>"", 
                                     :predefined_question_id= => 1,
                                     :save => true,
                                     :destroy => true,
                                     :nil? => false)
    
    @pdq_group = [@pdq1, @pdq2, @pdq3]
    
    PredefinedQuestion.stub!(:all).and_return(@pdq_group)
    @current_organization.stub!(:sponsored_surveys).and_return(@surveys_proxy)
    @surveys_proxy.stub!(:running).and_return(@open_surveys)
    @open_surveys.stub!(:find).and_return(@survey)
    @survey.stub!(:questions).and_return(@questions)
    @questions.stub!(:find_by_text).and_return(@question)
    @questions.stub!(:find_or_create_by_text).and_return(@question)
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
  
  it "should assign the found survey to the view" do
    do_update
    assigns(:survey).should equal(@survey)
  end
  
  it "should update the questions for the survey that are included in the params" do
    @questions.should_receive(:find_or_create_by_text).at_least(:once).and_return(@question)
    @question.should_receive(:attributes=).at_least(:once)
    @question.should_receive(:save).at_least(:once).and_return(true)
    
    do_update
  end
  
  it "should delete questions that are not included in the params" do
    @questions.should_receive(:find_by_text).at_least(:once).and_return(@question)
    @question.should_receive(:nil?).at_least(:once).and_return(false)
    @question.should_receive(:destroy).at_least(:once).and_return(true)
    
    do_update
  end

  it "should redirect to the show view page for this survey upon success" do
    do_update
    response.should redirect_to(survey_path(@survey))
  end
end
  
  describe SurveysController, " handling PUT /surveys/1, with failure" do
    before(:each) do
      @current_organization = mock_model(Organization)
      login_as(@current_organization)

      @survey = mock_model(Survey, :id => 1, :update_attributes => false, :sponsor => @current_organization, :job_title => "test")
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
      response.should redirect_to(edit_survey_path(@survey))
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
    @current_organization = mock_model(Organization)
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

describe SurveysController, "handling GET /surveys/search.xml" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
        
    @survey = mock_model(Survey, :id => 1, :title => "My Survey")
    @surveys = [@survey]    
    @surveys.stub!(:to_xml).and_return("XML")
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
    response.body.should == "XML"
  end
end

describe SurveysController, "handling POST /surveys/1/respond, as invitee that is not a shawarma user" do
  before(:each) do
    @survey = mock_model(Survey, :id => 1)
    @current_invitation = mock_model(SurveyInvitation, :survey => @survey)
    login_as(@current_invitation)
    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:questions).and_return([])
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
    flash[:notice].should eql("Survey was successfully completed!")
  end
end

describe SurveysController, "handling POST /surveys/1/respond, as organization based user" do
  before(:each) do
    @survey = mock_model(Survey, :id => 1)
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:questions).and_return([])
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
    flash[:notice].should eql("Survey was successfully completed!")
  end
end

describe SurveysController, "handling POST /surveys/1/respond, with invalid respones" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    @q1 = mock_model(Question, :id => 1, :attributes => "", :numerical_response? => false)
    @q2 = mock_model(Question, :id => 2, :attributes => "", :numerical_response? => false)
    @questions = [@q1, @q2]
    @survey = mock_model(Survey, :id => 1)
    @survey.stub!(:questions).and_return(@questions)
    @responses = []
    @my_response = mock_model(Response, :update_attributes => true, :valid? => false, :textual_response => "")
    @params = {:id => 1,
      :responses => {"1" => {:response => @my_response}, "2" => {:response => @my_response}}
    }
    
    Survey.stub!(:find).and_return(@survey)
    @current_organization.stub!(:responses).and_return(@responses)
    @responses.stub!(:find_or_create_by_question_id).and_return(@my_response)
  end
  
  def do_respond
    post :respond, @params
  end
  
  it "should flash error messages" do 
    do_respond
    flash[:notice].should eql("Please review and re-submit your responses.")
  end
  
  it "should render the surveys/id/questions page " do
    do_respond
    response.should redirect_to(survey_questions_path(@survey, :responses => @responses))
  end
  
  it "should assign the invalid responses to the view " do
    do_respond
    assigns[:responses].should_not be_nil
  end
  
end

describe SurveysController, " handling GET /surveys/my.xml" do
  
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @surveys = []
    @surveys.stub!(:to_xml).and_return("XML")
    
    @current_organization.stub!(:surveys).and_return(@surveys)

  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :my
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find all surveys for which the user has been invited or participated" do
    @current_organization.should_receive(:surveys).and_return(@surveys)
    
    do_get 
  end
  
  it "should render the found surveys as XML" do
    @surveys.should_receive(:to_xml).and_return("XML")
    do_get
  end
end



