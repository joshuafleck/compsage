require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/search" do

  before(:each) do
    render 'networks/search'
  end
  
  it "should have a means for submitting search text"
  it "should have a submit button"
  it "should render the list of networks"
  it "should render the search terms"
  it "should display the network attributes for all listed networks"
  it "should have a link to show each network"
  it "should have a link to edit any networks owned by the organization"
  it "should have a link to delete any networks owned by the organization"
  it "should have a link for leaving all listed networks if the org is a member"
  it "should have a link for joining all listed networks if the org is not a member"

end
