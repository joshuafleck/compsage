require File.dirname(__FILE__) + '/../../spec_helper'

describe "external invitation email" do

  before(:each) do
  
    @invitation = mock_model(ExternalInvitation, :message => 'message_text', :key => 'key_text', :name => 'name_text', :email => 'email_text')
    @organization = mock_model(Organization, :name => 'organization_name_text', :contact_name => 'contact_name_text')
    
    @invitation.stub!(:inviter).and_return(@organization)
    
    assigns[:invitation] = @invitation
    
  end
  
  def render_view
    render 'notifier/external_invitation_notification.text.html.erb'  
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
    @organization.should_receive(:name)
    render_view
  end
  
  it "should display the sender of the invitation's message" do
    @invitation.should_receive(:message)
    render_view
  end
  
  it "should link to the new account page" do
    render_view
    response.should have_tag("a[href=#{new_account_path(:key => 'key_text', :only_path => false)}]")
  end
  
end
