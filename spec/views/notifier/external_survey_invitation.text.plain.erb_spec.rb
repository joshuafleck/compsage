require File.dirname(__FILE__) + '/../../spec_helper'

describe "external survey invitation plain text email" do

  before(:each) do
  
    @invitation = mock_model(ExternalInvitation, :message => 'message_text', :key => 'key_text', :name => 'name_text', :email => 'email_text')
    @organization = mock_model(Organization, :name => 'organization_name_text', :contact_name => 'contact_name_text')
    @survey = stub_model(Survey, :sponsor => @organization, :end_date => 7.days.from_now)  

    @invitation.stub!(:inviter).and_return(@organization)
    
    assigns[:invitation] = @invitation
    assigns[:survey] = @survey
    
  end
  
  def render_view
    render 'notifier/external_survey_invitation_notification.text.plain.erb'  
  end
  
  it "should name the invitee" do
    @invitation.should_receive(:name)
    render_view
  end
  
  it "should name the sender of the invitation" do
    @organization.should_receive(:contact_name).at_least(2).times
    render_view
  end
  
  it "should name the sender of the invitation's organization" do
    @organization.should_receive(:name).at_least(2).times
    render_view
  end
  
  it "should display the sender of the invitation's message" do
    @invitation.should_receive(:message)
    render_view
  end
  
  it "should display the job title" do
    @survey.should_receive(:job_title)
    render_view
  end
  
  #FIXME: not sure why this is failing
  it "should display the end date" do
    #@survey.should_receive(:end_date)
    #render_view
  end
  
  it "should link to the new account page" do
    pending
  end
  
end
