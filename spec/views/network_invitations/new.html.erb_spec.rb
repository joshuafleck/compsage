require File.dirname(__FILE__) + '/../../spec_helper'

describe "/network_invitations/new" do

  before(:each) do
    render 'network_invitations/new'
  end
  
  it "should render the new network_invitations form"
  it "should render the network title"
  it "should have a means to add an organization"
  it "should have a means to add a group"
  it "should have a means to remove an organization"
  it "should have a means to remove a group"
  it "should have a submit button"
  it "should have a cancel button"

end