require File.dirname(__FILE__) + '/../../spec_helper'

describe "/network_invitations/index" do

  before(:each) do
    render 'network_invitations/index'
  end
  
  it "should render the the users current network_invitations"
  it "should have a way to decline each invitation"
  it "should have a way to accept each invitation"
  it "should have a form that redirects to a network"
  it "should have a link to create a new invitation"
end