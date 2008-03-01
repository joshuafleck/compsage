require File.dirname(__FILE__) + '/../../spec_helper'

describe "/invitations/show" do

  before(:each) do
    render 'invitations/show'
  end
  
  it "should render the invitation attributes"
  it "should have an accept button"
  it "should have a decline button"
  it "should show survey details if this is a survey invitation"
  it "should show a link to the network if this is a public network invitation"
  it "should show network details if this is a network invitation"  
  it "should list an inviter"
end