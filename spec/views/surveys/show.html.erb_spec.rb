require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/show" do

  before(:each) do  
    @owner = mock_model(ExternalSurveyInvitation)
    @current_organization_or_invitation = mock_model(Organization)
    template.stub!(:current_organization_or_invitation).and_return(@current_organization_or_invitation)
    
    @survey = mock_model(Survey, :job_title => "Software Engineer", :id => "1")
    @discussion_reply = mock_model(Discussion, :responder => @owner, :subject => "Reply Topic", :body => "Reply Body", :id => "2")
    @discussion_children = [@discussion_reply]
    @discussion_topic = mock_model(Discussion, :children => @discussion_children, :responder => @current_organization_or_invitation, :subject => "Root Topic", :body => "Root Body", :id => "1", :survey_id => @survey.id)
    @discussions = [@discussion_topic]
    
    @discussions.stub!(:sort).and_return(@discussions)
    @discussion_children.stub!(:sort).and_return(@discussion_children)
    
    assigns[:discussions] = @discussions
    assigns[:survey] = @survey
    assigns[:current_organization_or_invitation] = @current_organization_or_invitation
    
    render 'surveys/show'
  end
  
  it "should render the discussion index template" do
    response.should have_tag("#discussions")
  end
  
  it "should render the survey attributes" do
    pending
  end

  it "should have a link to see the results of a complete survey"
  it "should have the link to the survey questions if the user is invited or an organization"
  it "should have the a link to edit if user is the survey sponsor"

end
