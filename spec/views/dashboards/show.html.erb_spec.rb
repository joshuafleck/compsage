require File.dirname(__FILE__) + '/../../spec_helper'

describe "/dashboards/show" do
  before(:each) do
    render 'dashboards/show'
  end
  
  it "shows a count of survey invitations with a link to view the invitations"
  it "shows a count of network invitations with a link to view the invitations"
  it "shows a count of messages with a link to view the messages"
  it "shows a count of running surveys with activity with a link to the surveys"
  it "shows a count of recently completed surveys with a link to the surveys"
end
