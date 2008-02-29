require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/search" do

  before(:each) do
    render 'networks/search'
  end
  
  it "should have a means for submitting search text"
  it "should have a checkbox for allowing the org to search by title and/or description"
  it "should have a checkbox for excluding networks the org is already a member of"
  it "should have a submit button"
  it "should render the list of networks"
  it "should render the search terms"
  it "should display the network attributes for all listed networks including the number of members"
  it "should each network title with a link to show each network"
  it "should have a link for joining all listed networks the user is not a member of"
  it "should have a disabled link for joining all listed networks if the org is in private mode"
  it "should have a link to the index page"
  it "should have a link for leaving all listed networks of which the org is a member"
  it "should have a link for inviting users if the organization is the network owner and the network is private"
  it "should have a link for inviting users if the network is public"
  it "should have a link to edit any networks owned by the organization"
  it "should have a link to delete any networks owned by the organization"

end
