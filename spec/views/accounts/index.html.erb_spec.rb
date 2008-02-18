require File.dirname(__FILE__) + '/../../spec_helper'

describe "/accounts/index" do

  before(:each) do
    render 'accounts/index'
  end
  
  it "should display the email address"
  it "should display the public/private status"  
  it "should display the location"
  it "should display the city"
  it "should display the state"
  it "should display the name"
  it "should have an edit account link"  

end
