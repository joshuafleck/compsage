require File.dirname(__FILE__) + '/../spec_helper'

describe ReportsController, "#route_for" do  
  it "should map { :controller => 'reports', :action => 'show', :survey_id => 1 } to /surveys/1/report" do
    route_for(:controller => "reports", :action => "show", :survey_id => 1 ).should == "/surveys/1/report"
  end
  
  it "should map { :controller => 'reports', :action => 'chart', :survey_id => 1} to /surveys/1/report/chart" do
    route_for(:controller => "reports", :action => "chart", :survey_id => 1 ).should == "/surveys/1/report/chart"
  end
  
end

describe ReportsController, "handling GET /survey/1/report with current organization uninvited" do
  before do

    @current_organization_or_survey_invitation = mock_model(Organization, :id => 1)
    login_as(@current_organization_or_survey_invitation)
    
    @survey = mock_model(Survey, :all_invitations => [], :required_number_of_participations => 5)
    @participation = mock_model(Participation)
    @participations = mock('participations proxy', :size => 5, :find_by_survey_id => @participation)
    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:participations).and_return(@participations)
    @current_organization_or_survey_invitation.stub!(:participations).and_return(@participations)
    @participations.stub!(:belongs_to_invitee).and_return(@participations)
    @participations.stub!(:include?).and_return(false)
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
  
  it "should locate the participation for the current organization or survey invitation" do
    @current_organization_or_survey_invitation.should_receive(:participations).and_return(@participations)
    do_get
  end
    
  it "should find the participations from invited organizations" do
    @participations.should_receive(:belongs_to_invitee).and_return(@participations)
    do_get
  end  

  it "should determine if the current organization responded as an invitee" do
    @participations.should_receive(:include?).with(@participation).and_return(false)
    do_get
  end
  
  it "should assign the total participation count" do
    do_get
    assigns[:total_participation_count].should eql(@participations.size)
  end
  
  it "should assign the response methods for returning all responses" do
    do_get
    assigns[:responses_method].should eql('responses')
    assigns[:grouped_responses_method].should eql('grouped_responses')
    assigns[:adequate_responses_method].should eql('adequate_responses?')
  end  
  
end

describe ReportsController, "handling GET /survey/1/report with current organization invited" do
  before do

    @current_organization_or_survey_invitation = mock_model(Organization, :id => 1)
    login_as(@current_organization_or_survey_invitation)
    
    @survey = mock_model(Survey, :all_invitations => [], :required_number_of_participations => 5)
    @participation = mock_model(Participation)
    @participations = mock('participations proxy', :size => 5, :find_by_survey_id => @participation)
    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:participations).and_return(@participations)
    @current_organization_or_survey_invitation.stub!(:participations).and_return(@participations)
    @participations.stub!(:belongs_to_invitee).and_return(@participations)
    @participations.stub!(:include?).and_return(true)
  end
  
  def do_get
    get :show, :survey_id => 1
  end
  
  it "should be successful" do
    do_get
    
    response.should be_success
  end
  
  it "should assign the response methods for returning responses from invitees" do
    do_get
    assigns[:responses_method].should eql('invitee_responses')
    assigns[:grouped_responses_method].should eql('grouped_invitee_responses')
    assigns[:adequate_responses_method].should eql('adequate_invitee_responses?')
  end  
  
end

describe ReportsController, "handling GET /survey/1/report with inadequate participation for filtering uninvited responses" do
  before do

    @current_organization_or_survey_invitation = mock_model(Organization, :id => 1)
    login_as(@current_organization_or_survey_invitation)
    
    @survey = mock_model(Survey, :all_invitations => [], :required_number_of_participations => 5)
    @participation = mock_model(Participation)
    @participations = mock('participations proxy', :size => 1, :find_by_survey_id => @participation)
    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:participations).and_return(@participations)
    @current_organization_or_survey_invitation.stub!(:participations).and_return(@participations)
    @participations.stub!(:belongs_to_invitee).and_return(@participations)
    @participations.stub!(:include?).and_return(true)
  end
  
  def do_get
    get :show, :survey_id => 1
  end
  
  it "should be successful" do
    do_get
    
    response.should be_success
  end
  
  it "should assign the response methods for returning all responses" do
    do_get
    assigns[:responses_method].should eql('responses')
    assigns[:grouped_responses_method].should eql('grouped_responses')
  end  
  
end

describe ReportsController, "with access limits" do
  before do
    @survey = mock_model(Survey, :required_number_of_participations => 5)
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
  
  it "should return an error if the survey participation window is not finished" do
    pending
  end
end

describe ReportsController, "handling GET /survey/1/chart.xml" do
  before do

    @current_organization_or_survey_invitation = mock_model(Organization, :id => 1)
    login_as(@current_organization_or_survey_invitation)
    
    @survey = mock_model(Survey, :all_invitations => [], :required_number_of_participations => 5)
    @participation = mock_model(Participation)
    @participations = mock('participations proxy', :size => 3, :find_by_survey_id => @participation)
    
    Survey.stub!(:find).and_return(@survey)
    @survey.stub!(:participations).and_return(@participations)
    @current_organization_or_survey_invitation.stub!(:participations).and_return(@participations)
    @participations.stub!(:belongs_to_invitee).and_return(@participations)
    
    @question = mock_model(Question, :survey => @survey)
    Question.stub!(:find).and_return(@question)
    
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
