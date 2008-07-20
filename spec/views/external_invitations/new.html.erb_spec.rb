require File.dirname(__FILE__) + '/../../spec_helper'

describe "/external_invitations/new" do

  before(:each) do
    external_invitation = stub_model(ExternalInvitation)
    
    assigns[:invitation] = external_invitation
    
    render 'external_invitations/new'
  end
  
  it "should show the new form" do
  	response.should have_tag('form')
  end
  
  it "should have a means for allowing the organization an email address" do
  	response.should have_tag('input[id=invitation_email]')
  end
  
  it "should have a means for allowing the organization to input a name"	 do
  	response.should have_tag('input[id=invitation_name]')
  end
  
  it "should have a means for allowing the organization to input a message"	 do
  	response.should have_tag('textarea[id=invitation_message]')
  end
  
  it "should have a submit button" do
  	response.should have_tag('input[type=submit]')
  end
  
  it "should have a cancel link that links back to the start page" do
  	response.should have_tag('a[href=/]')
  end
   
end
