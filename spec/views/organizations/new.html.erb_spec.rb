require File.dirname(__FILE__) + '/../../spec_helper'

describe "/organizations/new" do
  before(:each) do
    render 'organizations/new'
  end
  
  it "should render the new form"
  it "should link to the terms of service"
  it "should ask for organization name"
  it "should ask for a location"
  it "should ask for an email"
  it "should have a submit button"
  
end
