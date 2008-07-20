require File.dirname(__FILE__) + '/../spec_helper'

describe ReportsController, "#route_for" do  
  it "should map { :controller => 'reports', :action => 'show', :survey_id => 1 } to /surveys/1/report" do
    route_for(:controller => "reports", :action => "show", :survey_id => 1 ).should == "/surveys/1/report"
  end
  
  it "should map { :controller => 'reports', :action => 'chart', :survey_id => 1} to /surveys/1/report/chart" do
    route_for(:controller => "reports", :action => "chart", :survey_id => 1 ).should == "/surveys/1/report/chart"
  end
  
end

describe ReportsController, "handling GET /survey/1/report" do
  before do
    @survey = mock_model(Survey)
    @organization = mock_model( Organization,
      valid_organization_attributes.with(
        :participations => mock(
          'participations_proxy', :find_by_survey_id => mock_model(Participation, :survey_id => @survey.id)
        )
      )
    )
    
    login_as(@organization)
    
    Survey.stub!(:find).and_return(@survey)
  end
  
  def do_get
    get :show, :survey_id => 1
  end
  
  it "should be successful" do
    do_get
    
    response.should be_success
  end
  
  it "should find the survey" do
    Survey.should_receive(:find).and_return(@survey)
    
    do_get
  end
end

describe ReportsController, "with access limits" do
  before do
    @survey = mock_model(Survey)
    @organization = mock_model( Organization,
      valid_organization_attributes.with(
        :participations => mock(
          'participations_proxy', :find_by_survey_id => nil
        )
      )
    )
    
    login_as(@organization)
    
    Survey.stub!(:find).and_return(@survey)
  end
  
  def do_get
    get :show, :survey_id => 1
  end
  
  it "should return an error if the organization has not responded to the survey or isn't the sponsor" do
    do_get
    
    response.should_not be_success
  end
  
  it "should return an error if the survey participation window is not finished"
end

describe ReportsController, "handling GET /survey/1/chart.xml" do
  before do
    @survey = mock_model(Survey)
    @organization = mock_model( Organization,
      valid_organization_attributes.with(
        :participations => mock(
          'participations_proxy', :find_by_survey_id => mock_model(Participation, :survey_id => @survey.id)
        )
      )
    )
    
    login_as(@organization)
    
    Question.stub!(:find).and_return("question")
  end
  
  def do_get
    get :chart, :survey_id => 1, :question_id => 1
  end
  
  it "should be successful" do
    do_get
    
    response.should be_success
  end
  
  it "should find the specified question" do
    Question.should_receive(:find, :with => 1)
    
    do_get
  end
end

describe ReportsController, "handling GET /responses/1.xml" do
  it "should be successful"
  it "should find all the survey's questions"
  it "should find all the survey's questions' responses"
  it "should render the aggregate report as xml"
end