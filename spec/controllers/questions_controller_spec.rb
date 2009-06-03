require File.dirname(__FILE__) + '/../spec_helper'


describe QuestionsController, "#route_for" do
  
  it "should map { :controller => 'questions', :action => 'index', :survey_id => '1' } to /surveys/1/questions" do
    route_for(:controller => "questions", :action => "index", :survey_id => '1').should == "/surveys/1/questions"
  end
  
  it "should map { :controller => 'questions', :action => 'preview', :survey_id => '1' } to /surveys/1/questions/preview" do
    route_for(:controller => "questions", :action => "preview", :survey_id => '1').should == "/surveys/1/questions/preview"
  end
  
  it "should map { :controller => 'questions', :action => 'create', :survey_id => '1' } to /surveys/1/questions" do
    route_for(:controller => "questions", :action => "create", :survey_id => '1').should == { :path => "/surveys/1/questions", :method => :post }
  end 
  
  it "should map { :controller => 'questions', :action => 'destroy', :survey_id => '1', :id => '1' } to /surveys/1/questions/1" do
    route_for(:controller => "questions", :action => "destroy", :survey_id => '1', :id => '1' ).should == { :path => "/surveys/1/questions/1", :method => :delete }
  end      
  
  it "should map { :controller => 'questions', :action => 'update', :survey_id => '1', :id => '1' } to /surveys/1/questions/1" do
    route_for(:controller => "questions", :action => "update", :survey_id => '1', :id => '1' ).should == { :path => "/surveys/1/questions/1", :method => :put }
  end 
  
  it "should map { :controller => 'questions', :action => 'move', :survey_id => '1', :id => '1' } to /surveys/1/questions/1/move" do
    route_for(:controller => "questions", :action => "move", :survey_id => '1', :id => '1' ).should == { :path => "/surveys/1/questions/1/move", :method => :put }
  end          
    
end

describe QuestionsController, "handling GET /questions" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:survey)
    
    @participation = mock_model(Participation, :responses => [])
    @participations = []
    @participations.stub!(:find_or_initialize_by_survey_id).and_return(@participation)

    @current_organization.stub!(:participations).and_return(@participations)
    Survey.stub!(:find).and_return(@survey)
  end
  
  def do_get
    get :index, :survey_id => @survey.id
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the survey" do
    Survey.should_receive(:find).and_return(@survey)
    do_get
  end
  
  it "should find or create a new participation" do
    @participations.should_receive(:find_or_initialize_by_survey_id).and_return(@participation)
    do_get
  end  
  
  it "should assign the found survey to the view" do
    do_get
    assigns[:survey].should_not be_nil
  end
  
  it "should assign the participation to the view" do
    do_get
    assigns[:participation].should_not be_nil
  end  
  
  it "should render the questions view template" do
    do_get
    response.should render_template('index')
  end
end

describe QuestionsController, "handling GET /questions.xml" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:survey)
    @survey.stub!(:questions).and_return(mock_model(Question, :to_xml => "XML"))
    
    Survey.stub!(:find).and_return(@survey)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index, :survey_id => @survey.id
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find questions for the survey" do
    Survey.should_receive(:find).and_return(@survey)    
    do_get
  end
  
  it "should render the found questions as XML" do
    do_get
    response.body.should eql("XML")
  end
end

describe QuestionsController, "handling POST /questions" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:survey)
    @question = Factory(:question, :survey => @survey)
    @survey.questions.stub!(:new).and_return(@question)

    @sponsored_surveys_mock = mock(:sponsored_surveys_mock, :find => @survey)
    @current_organization.stub!(:sponsored_surveys).and_return(@sponsored_surveys_mock)
    
    @params = {:survey_id => @survey.id}
  end
  
  def do_post
    @request.env["HTTP_ACCEPT"] = "application/javascript"
    post :create, @params
  end
  
  it "should be successful" do
    do_post
    response.should be_success
  end
  
  it "should find the survey" do
    @sponsored_surveys_mock.should_receive(:find).and_return(@survey)
    do_post
  end
  
  describe "when creating a predefined question" do
    before do
      @predefined_question = Factory(:predefined_question)
      @predefined_question.stub!(:build_questions).and_return(@question)
      
      PredefinedQuestion.stub!(:find).and_return(@predefined_question)
      
      @params.merge!({:predefined_question_id => @predefined_question.id.to_s})
    end
    
    it "should find the predefined question" do
      PredefinedQuestion.should_receive(:find).and_return(@predefined_question)
      do_post
    end
    
    it "should build the questions for the PDQ" do
      @predefined_question.should_receive(:build_questions)
      do_post
    end
    
  end
  
  describe "when creating a custom question" do
    
    it "should create a new question" do
      @survey.questions.should_receive(:new).and_return(@question)
      do_post
    end
    
  end  
    
  it "should render the questions partial" do
    do_post
    response.should render_template(:question)
  end
    
end

describe QuestionsController, "handling PUT /questions/1" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:survey)
    @question = Factory(:question, :survey => @survey)
    @survey.questions.stub!(:find).and_return(@question)
    @question.stub!(:update_attributes).and_return(true)

    @sponsored_surveys_mock = mock(:sponsored_surveys_mock, :find => @survey)
    @current_organization.stub!(:sponsored_surveys).and_return(@sponsored_surveys_mock)
    
    @params = {:survey_id => @survey.id, :id => @question.id}
  end
  
  def do_put
    @request.env["HTTP_ACCEPT"] = "application/javascript"
    put :update, @params
  end
  
  it "should be successful" do
    do_put
    response.should be_success
  end
  
  it "should find the survey" do
    @sponsored_surveys_mock.should_receive(:find).and_return(@survey)
    do_put
  end
  
  it "should find the question" do
    @survey.questions.should_receive(:find).and_return(@question)
    do_put
  end  
  
  it "should update the question" do
    @question.should_receive(:update_attributes).and_return(true)
    do_put
  end   
  
  it "should render the questions partial" do
    do_put
    response.should render_template(:question)
  end
    
end

describe QuestionsController, "handling DELETE /questions/1" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:survey)
    @question = Factory(:question, :survey => @survey)
    @survey.questions.stub!(:find).and_return(@question)
    @question.stub!(:destroy)

    @sponsored_surveys_mock = mock(:sponsored_surveys_mock, :find => @survey)
    @current_organization.stub!(:sponsored_surveys).and_return(@sponsored_surveys_mock)
    
    @params = {:survey_id => @survey.id, :id => @question.id}
  end
  
  def do_delete
    @request.env["HTTP_ACCEPT"] = "application/javascript"
    delete :destroy, @params
  end
  
  it "should find the survey" do
    @sponsored_surveys_mock.should_receive(:find).and_return(@survey)
    do_delete
  end
  
  it "should find the question" do
    @survey.questions.should_receive(:find).and_return(@question)
    do_delete
  end  
  
  it "should delete the question" do
    @question.should_receive(:destroy)
    do_delete
  end   
  
end

describe QuestionsController, "handling PUT /questions/1/move" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:survey)
    @question = Factory(:question, :survey => @survey)
    @survey.questions.stub!(:find).and_return(@question)
    @question.stub!(:move_lower)
    @question.stub!(:move_higher)

    @sponsored_surveys_mock = mock(:sponsored_surveys_mock, :find => @survey)
    @current_organization.stub!(:sponsored_surveys).and_return(@sponsored_surveys_mock)
    
    @params = {:survey_id => @survey.id, :id => @question.id}
  end
  
  def do_move
    @request.env["HTTP_ACCEPT"] = "application/javascript"
    put :move, @params
  end
  
  it "should find the survey" do
    @sponsored_surveys_mock.should_receive(:find).and_return(@survey)
    do_move
  end
  
  it "should find the question" do
    @survey.questions.should_receive(:find).and_return(@question)
    do_move
  end  
  
  describe "when moving the question higher" do
    before do
      @params.merge!({:direction => "higher"})
    end
  
    it "should move the question higher" do
      @question.should_receive(:move_higher)
      do_move
    end   
    
  end

  describe "when moving the question lower" do
    before do
      @params.merge!({:direction => "lower"})
    end
  
    it "should move the question lower" do
      @question.should_receive(:move_lower)
      do_move
    end   
    
  end

end
