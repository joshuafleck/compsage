require File.dirname(__FILE__) + '/../../spec_helper'

describe "/invitations/show" do

  before(:each) do
    render 'invitations/show'
  end
  
  it "should render the invitation attributes"
  it "should render one invitation"
  it "should have an accept button"
  it "should have a decline button"
  it "should list an inviter"
end