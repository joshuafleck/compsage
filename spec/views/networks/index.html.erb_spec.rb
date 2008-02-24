require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/index" do

  before(:each) do
    render 'networks/index'
  end
  
  it "should render the list of networks"
  it "should display the title and number of members in all listed networks"
  it "should have a link to show each network"
  it "should have a link to edit any networks owned by the organization"
  it "should have a link to delete any networks owned by the organization"
  it "should have a link for creating a new network"
  it "should have a disabled link for creating a new network if the org is in private mode"
  it "should have a link for leaving all listed networks of which the org is a member"
  it "should have a link for inviting users if the organization is the network owner"

end
