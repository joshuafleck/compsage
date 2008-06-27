require File.dirname(__FILE__) + '/../../spec_helper'

describe "external network invitation html email" do

  before(:each) do
  
    @network = stub_model(Network, :id => '1')
    @invitation = mock_model(ExternalNetworkInvitation, :message => 'message_text', :key => 'key_text', :name => 'name_text', :email => 'email_text')
    @organization = mock_model(Organization, :name => 'organization_name_text', :contact_name => 'contact_name_text')
    
    @invitation.stub!(:inviter).and_return(@organization)
    
    assigns[:invitation] = @invitation
    assigns[:network] = @network
    
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
  
  it "should link to the new account page, with a network_id param" do
    render_view
    response.should have_tag("a[href='http://test.host/account/new?key=key_text&amp;network_id=1']")
    #FIXME: had to escape ampersand to get URL to match
    #response.should have_tag("a[href=#{new_account_path(:key => 'key_text', :network_id => @network.id, :only_path => false)}]")
  end
  
end
