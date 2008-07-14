require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/my" do

  before(:each) do
    @survey = mock_model(Survey)
    organization = stub_model(Organization)
    
    template.stub!(:current_organization).and_return(organization)
    
    @survey.stub!(:job_title).and_return("TEST")
    @survey.stub!(:sponsor).and_return(organization)
    @survey.stub!(:id).and_return("1")
    @survey.stub!(:end_date).and_return(Time.now)
    
    assigns[:surveys] = [@survey]
    
    render 'surveys/my'
  end
  
  it "should render the a list of surveys and their attributes" do
    response.should have_tag("ul[id=surveys]")
  end
  
  it "should have an edit button for each sponsored survey" do
    response.should have_tag("a[href=#{edit_survey_path(@survey.id)}]")
  end
  
  it "should have a link to see each survey" do
    response.should have_tag("a[href=#{survey_path(@survey.id)}]")
  end
  
  it "should have a link to invite users to the survey if the organization is the sponsor" do
    response.should have_tag("a[href=#{new_survey_invitation_path(@survey.id)}]")
  end
  
  it "should be paged if the user has more then X surveys" do
    pending
  end
  
  it "should allow the user to select the X number of surveys to show per page" do
    pending
  end
  
  it "should have a form to search surveys" do
    pending
  end
end
