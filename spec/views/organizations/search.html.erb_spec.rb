require File.dirname(__FILE__) + '/../../spec_helper'

describe "/organizations/search" do
  before(:each) do
    render 'organizations/search'
  end
  
  it "should show the search terms"
  it "should show the found organization's name"
  it "should show the found organization's location"
  it "should have a link to send each organization a message"
end