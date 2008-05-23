require File.dirname(__FILE__) + '/../spec_helper'


describe QuestionsController, "#route_for" do
  
  it "should map { :controller => 'questions', :action => 'index', :survey_id => 1 } to /surveys/1/questions" do
    route_for(:controller => "questions", :action => "index", :survey_id => 1).should == "/surveys/1/questions"
  end
  
  it "should map { :controller => 'questions', :action => 'show', :id => 1, :survey_id => 1 } to /surveys/1/questions/1" do
    #route_for(:controller => "questions", :action => "show", :id => 1, :survey_id => 1).should == "/surveys/1/questions/1"
  end
  
  it "should map { :controller => 'questions', :action => 'update', :id => 1, :survey_id => 1 } to /surveys/1/questions/1" do
    #route_for(:controller => "questions", :action => "update", :id => 1, :survey_id => 1).should == "/surveys/1/questions/1"
  end
  
  it "should map { :controller => 'questions', :action => 'destroy', :id => 1, :survey_id => 1 } to /surveys/1/questions/1" do
    #route_for(:controller => "questions", :action => "destroy", :id => 1, :survey_id => 1).should == "/surveys/1/questions/1"
  end
  
end

#Questions index will be used to view the questions
describe QuestionsController, "handling GET /questions" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @surveys_proxy = mock('surveys proxy')
    @open_surveys_proxy = []
    @open_surveys = []
    @questions = []
    
    @current_organization.stub!(:surveys).and_return(@surveys_proxy)
    @surveys_proxy.stub!(:open).and_return(@open_surveys_proxy)
    @open_surveys_proxy.stub!(:find).and_return(@open_surveys)
    @open_surveys.stub!(:questions).and_return(@questions)
  end
  
  def do_get
    get :index, :survey_id => 1
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find questions for the survey" do
    @current_organization.should_receive(:surveys).and_return(@surveys_proxy)
    @surveys_proxy.should_receive(:open).and_return(@open_surveys_proxy)
    @open_surveys_proxy.should_receive(:find).and_return(@open_surveys)
    @open_surveys.should_receive(:questions).and_return(@questions)
    
    do_get
  end
  
  it "should assign the found questions to the view" do
    do_get
    assigns[:questions].should_not be_nil
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
    
    @surveys_proxy = mock('surveys proxy')
    @open_surveys_proxy = []
    @open_surveys = []
    @questions = []
    
    @current_organization.stub!(:surveys).and_return(@surveys_proxy)
    @surveys_proxy.stub!(:open).and_return(@open_surveys_proxy)
    @open_surveys_proxy.stub!(:find).and_return(@open_surveys)
    @open_surveys.stub!(:questions).and_return(@questions)
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
    @current_organization.should_receive(:surveys).and_return(@surveys_proxy)
    @surveys_proxy.should_receive(:open).and_return(@open_surveys_proxy)
    @open_surveys_proxy.should_receive(:find).and_return(@open_surveys)
    @open_surveys.should_receive(:questions).and_return(@questions)
    
    do_get
  end
  
  it "should render the found questions as XML" do
    do_get
    response.body.should == "XML"
  end
end


describe QuestionsController, "handling GET /questions, when survey is closed" do
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @surveys_proxy = mock('surveys proxy')
    @open_surveys_proxy = []
    
    @current_organization.stub!(:surveys).and_return(@surveys_proxy)
    @surveys_proxy.stub!(:open).and_return(@open_surveys_proxy)
    @open_surveys_proxy.stub!(:find).and_raise(ActiveRecord::RecordNotFound)
  end
  
  def do_get
    get :index, :survey_id => 1
  end
  
  it "should redirect to the report for the survey" do
    do_get
    response.should redirect_to(survey_report_path("1"))
  end
  it "should flash a message clarifying that the survey is closed" do
    do_get
    flash[:notice].should eql("The report you are trying to access is closed.")
  end
end



# These specs will not be developed until phase two
# required for more advanced question creation, instead
# of simple form we will use for phase one.
describe QuestionsController, "handling GET /questions/1.xml" do
  it "should be successful"
  it "should render the question as xml"
  it "should find the question requested"
  it "should return an error if the current organization is not invited to the survey"
  it "should return xml"
end

describe QuestionsController, "handling POST /questions from xml" do
  it "should create a new question"
  it "should return an error without a survey specified"
  it "should return an error if the current organization is not the owner of the survey"
  it "should return an error if the survey is closed"
end

describe QuestionsController, "handling PUT /questions/1.xml from xml" do 
  it "should update the specified question's attributes"
  it "should return an error if the survey is closed"
  it "should return an error when the question belongs to a survey that doesn't belong to the current organization"
end

describe QuestionsController, "handling DELETE /questions/1.xml from xml" do
  it "should find the requested question"
  it "should destroy the specified question"
  it "should return an error if the survey is closed"
  it "should return an error when the question belongs to a survey that doesn't belong to the current organization"
end