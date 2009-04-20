require File.dirname(__FILE__) + '/../spec_helper'


describe QuestionsController, "#route_for" do
  
  it "should map { :controller => 'questions', :action => 'index', :survey_id => '1' } to /surveys/1/questions" do
    route_for(:controller => "questions", :action => "index", :survey_id => '1').should == "/surveys/1/questions"
  end
  
  it "should map { :controller => 'questions', :action => 'preview', :survey_id => '1' } to /surveys/1/questions/preview" do
    route_for(:controller => "questions", :action => "preview", :survey_id => '1').should == "/surveys/1/questions/preview"
  end  
    
end

#Questions index will be used to view the questions
describe QuestionsController, "handling GET /questions" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    @survey = mock_model(Survey, :questions => [])
    
    @participation = mock_model(Participation, :responses => [])
    @participations = []
    @participations.stub!(:find_or_initialize_by_survey_id).and_return(@participation)

    @current_organization.stub!(:participations).and_return(@participations)
    Survey.stub!(:find).and_return(@survey)
  end
  
  def do_get
    get :index, :survey_id => 1
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the survey" do
    Survey.should_receive(:find).and_return(@survey)
    do_get
  end
  
  it "should assign the found survey to the view" do
    do_get
    assigns[:survey].should_not be_nil
  end
  
  it "should render the questions view template" do
    do_get
    response.should render_template('index')
  end
end

describe QuestionsController, "handling GET /questions.xml" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
  
    @questions = []
    @survey = mock_model(Survey, :questions => @questions)
    
    @participation = mock_model(Participation, :responses => [])
    @participations = []
    @participations.stub!(:find_or_initialize_by_survey_id).and_return(@participation)

    @current_organization.stub!(:participations).and_return(@participations)
    
    Survey.stub!(:find).and_return(@survey)
    @questions.stub!(:to_xml).and_return("XML") 
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index, :survey_id => 1
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
    response.body.should == "XML"
  end
end

