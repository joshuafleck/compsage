require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/show with xml" do
  before(:each) do
    render 'accounts/show.xml.builder'
  end
  
  it "should contain the email address"
  it "should contain the public/private status"  
  it "should contain the location"
  it "should contain the city"
  it "should contain the state"
  it "should contain the name"
  
end
