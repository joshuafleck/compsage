require File.dirname(__FILE__) + '/../../spec_helper'

describe "/invitations/index" do

  before(:each) do
    @logo = mock_model(Logo, :public_filename => "TEST")
    @organization = mock_model(Organization, :logo => @logo, :name => "TEST")
    @survey = mock_model(Survey, :job_title => "TEST")
    @survey_invitation = mock_model(SurveyInvitation, :survey => @survey, :inviter => @organization)
    @survey_invitations = [@survey_invitation]
    @network_invitations = []
    
    assigns[:survey_invitations] = @survey_invitations
    assigns[:network_invitations] = @network_invitations
  
    render 'invitations/index'
  end
  
  it "should render the invitation attributes" do
    response.should have_tag("span","Inviter:")
    response.should have_tag("span","Survey:")
  end
  
  it "should render a list of invited networks" do
    response.should have_tag("ul[id=network_invitations]")
  end
  
  it "should render a list of invited surveys" do
    response.should have_tag("ul[id=survey_invitations]")
  end
  
  it "should have one or more accept button" do
    response.should have_tag("a","Take Survey")
  end
  
  it "should have one or more decline button" do
    response.should have_tag("a","Decline")
  end

end
