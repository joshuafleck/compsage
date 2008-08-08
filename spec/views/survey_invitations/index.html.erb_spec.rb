require File.dirname(__FILE__) + '/../../spec_helper'

describe "/survey_invitations/index" do

  before(:each) do
    
    @current_organization = mock_model(Organization, :networks => [])
    
    invitee = stub_model(Organization, :name => 'invitee')
    
    @invitation_1 = mock_model(Invitation, :invitee => invitee)
    @invitation_2 = mock_model(Invitation, :invitee => invitee)

    @external_invitation_1 = mock_model(ExternalSurveyInvitation, :email => 'invitee@invitee.com', :organization_name => nil)
    @external_invitation_2 = mock_model(ExternalSurveyInvitation, :email => 'invitee@invitee.com', :organization_name => 'test')
    
    assigns[:external_invitations] = [@external_invitation_1, @external_invitation_2]
    assigns[:survey] = stub_model(Survey, :name => 'Test Survey')
    assigns[:invitations] = [@invitation_1, @invitation_2]
    assigns[:current_organization] = @current_organization
    
    render 'survey_invitations/index'
  end
  
  it "should render the a list of invitations for a survey" do
     response.should have_tag('ul[id=invitations]')
  end
  
  it "should render the the current external invitations" do
     response.should have_tag('ul[id=external_invitations]')
  end
  
  it "should have a form that redirects to a survey" do
    response.should have_tag("form")
  end
  
  it "should have a delete button for each invitation" do
    response.should have_tag("a[href=#{survey_invitation_path(assigns[:survey], @invitation_1)}]")
    response.should have_tag("a[href=#{survey_invitation_path(assigns[:survey], @invitation_2)}]")
  end
  
  it "should have a Invite! button" do
    response.should have_tag("input[type=submit]")
  end
  
  it "should have a Done link" do
    response.should have_tag("a","Done")
  end
  
end
