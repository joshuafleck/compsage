require File.dirname(__FILE__) + '/../spec_helper'

describe ReportsController, "#route_for" do  
  it "should map { :controller => 'reports', :action => 'show', :survey_id => '1' } to /surveys/1/report" do
    route_for(:controller => "reports", :action => "show", :survey_id => '1' ).should == "/surveys/1/report"
  end
  
  it "should map { :controller => 'reports', :action => 'chart', :survey_id => '1'} to /surveys/1/report/chart" do
    route_for(:controller => "reports", :action => "chart", :survey_id => '1' ).should == "/surveys/1/report/chart"
  end
  
end

describe ReportsController, "handling GET /survey/1/report" do
  before do
    @current_organization_or_survey_invitation = Factory(:organization)
    login_as(@current_organization_or_survey_invitation)
    
    @survey = Factory(:finished_survey, :sponsor => @current_organization_or_survey_invitation)
    Factory(:participation, :survey => @survey, :participant => @current_organization_or_survey_invitation)
    Factory(:invoice, :survey => @survey)
    5.times do
      @org = Factory(:organization)
      Factory(:participation, :survey => @survey, :participant => @org)
      Factory(:survey_invitation, :survey => @survey, :inviter => @current_organization_or_survey_invitation, :invitee => @org)
    end
  end
  
  def do_get
    get :show, :survey_id => @survey.id
    @survey.reload
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
    
  it "should assign the invitations to the view" do
    do_get
    assigns[:invitations].should_not be_nil
  end
  
  it "should assign the survey to the view" do
    do_get
    assigns[:survey].should == @survey
  end
  
  it "should assign the participations to the view" do
    do_get
    assigns[:participations].should == @survey.participations
  end
end

describe ReportsController, "handling GET /survey/1/report with an undelivered invoice" do
  before(:each) do
    @current_organization_or_survey_invitation = Factory(:organization)
     login_as(@current_organization_or_survey_invitation)

     @survey = Factory(:finished_survey, :sponsor => @current_organization_or_survey_invitation)
     Factory(:participation, :survey => @survey, :participant => @current_organization_or_survey_invitation)
     Factory(:invoice, :survey => @survey, :payment_type => 'invoice')
  end
  
  def do_get
    get :show, :survey_id => @survey.id
    @survey.reload
  end

  it "should redirect the user to the billing page" do
    do_get
    response.should redirect_to(survey_billing_path(@survey))
  end
end


describe ReportsController, "handling GET /survey/1/report with a user who didn't respond" do
  before do
    @survey = Factory(:finished_survey)
    @organization = Factory(:organization)
    
    login_as(@organization)
  end
  
  def do_get
    get :show, :survey_id => @survey.id
  end
  
  it "should return an error if the organization has not responded to the survey or isn't the sponsor" do
    do_get
    response.should_not be_success
  end
end

describe ReportsController, "handling GET /survey/1/chart.xml" do
  before do
    @current_organization_or_survey_invitation = Factory(:organization)
    login_as(@current_organization_or_survey_invitation)
    
    @survey = Factory(:finished_survey, :sponsor => @current_organization_or_survey_invitation )
    Factory(:participation, :survey => @survey, :participant => @current_organization_or_survey_invitation)
    
    5.times do
      Factory(:participation, :survey => @survey, :participant => Factory(:organization))
    end
    
    @question = Factory(:question, :survey => @survey, :responses => [])
  end
  
  def do_get
    get :chart, :survey_id => @survey.id, :question_id => @question.id, :format => "xml"
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should assign the survey and participations to the view" do
    do_get
    assigns[:survey].should == @survey
  end
  
  it "should assign the survey participations to the view" do
    do_get
    assigns[:participations].should == @survey.participations
  end
end

describe ReportsController, "handling PUT /survey/1/suspect" do
  before(:each) do
    @current_organization_or_survey_invitation = Factory(:organization)
    login_as(@current_organization_or_survey_invitation)
    
    @survey = Factory(:finished_survey, :sponsor => @current_organization_or_survey_invitation )
  end
  
  def do_post
    post :suspect, :survey_id => @survey.id, :comment => 'This is a comment!', :format => 'js'
    
  end
  
  it "should be successful" do
    do_post
    response.should be_success
  end
  
  it "should note the survey as being reported suspect"
  
end
