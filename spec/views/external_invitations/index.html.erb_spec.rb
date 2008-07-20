require File.dirname(__FILE__) + '/../../spec_helper'

describe "external_invitations/index" do

before(:each) do

    external_invitation = stub_model(ExternalInvitation)
    external_invitation.stub!(:created_at).and_return(Time.now)
    
    assigns[:invitations] = [external_invitation]
    
    render 'external_invitations/index'
  end
  
  it "should render a list of external_invitations" do
    response.should have_tag('ul[id=invitations]') 
  end
  
end
