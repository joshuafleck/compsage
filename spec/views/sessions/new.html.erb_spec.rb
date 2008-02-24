require File.dirname(__FILE__) + '/../../spec_helper'

describe "/session/new" do
  before(:each) do
    render 'session/new'
  end
  
  it "should display an email field"
  it "should display a password field"
  it "should ask to remember me"
  it "should have a submit button"
  it "should have a link to reset password"
  it "should have a link to sign up"
end
