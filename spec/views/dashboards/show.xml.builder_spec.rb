require File.dirname(__FILE__) + '/../../spec_helper'

describe "/dashboards/show with xml" do
  before(:each) do
    render 'dashboards/show.xml.builder'
  end
  
  it "should contain links to survey invitations received since last login"
  it "should contain links to network invitations received since last login"
  it "should contain links to messages received since last login"
  it "should contain links to running surveys with activity since last login"
  it "should contain links to completed surveys since last login"
  
end
