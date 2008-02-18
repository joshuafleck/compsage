require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/search" do

  before(:each) do
    render 'networks/search'
  end
  
  it "should have a means for submitting search text"
  it "should have a checkbox for allowing the org to search by title and/or description"
  it "should have a submit button"
  it "should render the list of networks"
  it "should render the search terms"
  it "should display the network attributes for all listed networks including the number of members"
  it "should each network title with a link to show each network"
  it "should have a link for joining all listed networks"
  it "should have a link to the index page"

end
