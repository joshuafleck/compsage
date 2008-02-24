require File.dirname(__FILE__) + '/../../spec_helper'

describe "/organizations/show" do
  before(:each) do
    render 'organizations/show'
  end
  
  it "should show the organization name and location"
  it "should show the contacts at that organization"
  it "should have a button to send this organization a message"
end
