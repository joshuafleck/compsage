require File.dirname(__FILE__) + '/../../spec_helper'

describe "/invitations/index" do

  before(:each) do
    render 'invitations/index'
  end
  
  it "should render the invitation attributes"
  it "should render a list of invited networks"
  it "should render a list of invited surveys"
  it "should have one or more accept button"
  it "should have one or more decline button"

end