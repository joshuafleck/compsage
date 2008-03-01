require File.dirname(__FILE__) + '/../../spec_helper'

describe "/network_invitations/index" do

  before(:each) do
    render 'network_invitations/index'
  end
  
  it "should render the the users current invitations for a network"
  it "should have a way to delete an invitation"
  it "should have a form that redirects to a network"
  it "should have a link to create a new invitation"
end