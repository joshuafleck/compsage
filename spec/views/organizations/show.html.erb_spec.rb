require File.dirname(__FILE__) + '/../../spec_helper'

describe "/organizations/show" do
  before(:each) do
    render 'organizations/show'
  end
  
  it "should show the organization name"
  it "should show the organization's location name"
  it "should show the organization's city"
  it "should show the organization's state"
  it "should show the contacts at that organization"
  it "should have a button to send this organization a message"
  it "should show the organization's logo if one exists"
  it "should show a generic logo if one doesn't exist"
  it "should list the organization's joined networks"
end
