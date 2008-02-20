require File.dirname(__FILE__) + '/../../spec_helper'

describe "/network_invitations/show" do

  before(:each) do
    render 'network_invitations/show'
  end
  
  it "should render the network_invitations attributes"
  it "should have a decline button"
  it "should have an accept button"
  it "should have a form that redirects to a network"
end