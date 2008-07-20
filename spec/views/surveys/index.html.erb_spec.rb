require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/index" do

  before(:each) do
    @survey = mock_model(Survey)
    organization = stub_model(Organization)
    survey_invitation = mock_model(SurveyInvitation)
    
    template.stub!(:current_organization).and_return(organization)
    
    @survey.stub!(:job_title).and_return("TEST")
    @survey.stub!(:sponsor).and_return(organization)
    @survey.stub!(:id).and_return("1")
    @survey.stub!(:end_date).and_return(Time.now)
    
    survey_invitation.stub!(:survey).and_return(@survey)
    survey_invitation.stub!(:id).and_return("1")
    
    assigns[:surveys] = [@survey]
    assigns[:invited_surveys] = [survey_invitation]
    
    render 'surveys/index'
  end
  
  it "should render the a list of surveys and their attributes" do
    response.should have_tag("ul[id=surveys]")
  end
  
  it "should render the a list of survey invitations" do
    response.should have_tag("ul[id=invited_surveys]")
  end
  
  it "should have an edit button for each sponsored survey" do
    response.should have_tag("a[href=#{edit_survey_path(@survey.id)}]")
  end
  
  it "should have a link to see each survey" do
    response.should have_tag("a[href=#{survey_path(@survey.id)}]")
  end
  
  it "should have a link to invite users to the survey if the organization is the sponsor" do
    response.should have_tag("a[href=#{survey_invitations_path(@survey.id)}]")
  end
  
  it "should be paged if the user has more then X surveys" do
    pending
  end
  
  it "should allow the user to select the X number of surveys to show per page" do
    pending
  end
  
  it "should have a form to search surveys" do
    response.should have_tag("form[action=#{search_surveys_path()}]")
  end
end
