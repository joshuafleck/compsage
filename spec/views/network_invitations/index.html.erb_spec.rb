require File.dirname(__FILE__) + '/../../spec_helper'

describe "/network_invitations/index" do

  before(:each) do
    assigns[:network] = mock_model(Network, :name => 'Test Network')
    
    invitee = mock_model(Organization, :name => 'invitee')
    
    @invitation_1 = mock_model(Invitation, :invitee => invitee)
    @invitation_2 = mock_model(Invitation, :invitee => invitee)
    assigns[:invitations] = [@invitation_1, @invitation_2]
    render 'network_invitations/index'
  end
  
  it "should render the the current invitations" do
     response.should have_tag('ul[id=invitations]')
  end
  
  it "should have a way to delete an invitation" do
    response.should have_tag("a[href=#{network_invitation_path(assigns[:network], @invitation_1)}]")
    response.should have_tag("a[href=#{network_invitation_path(assigns[:network], @invitation_2)}]")
  end
  
  it "should have a form" do
    response.should have_tag("form")
  end
  
end