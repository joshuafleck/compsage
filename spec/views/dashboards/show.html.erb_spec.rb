require File.dirname(__FILE__) + '/../../spec_helper'

describe "/dashboards/show" do
  before(:each) do
    render 'dashboards/show'
  end
  
  it "shows survey invitations with a link to view the invitations"
  it "shows network invitations with a link to view the invitations"
  it "shows messages with a link to view the messages"
  it "shows running surveys with activity with a link to the surveys"
  it "shows recently completed surveys with a link to the surveys"
  it "has a link for creating a new survey"
end
