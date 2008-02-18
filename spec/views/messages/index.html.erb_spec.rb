require File.dirname(__FILE__) + '/../../spec_helper'

describe "/messages/index" do

  before(:each) do
    render 'messages/index'
  end

  it "should render the list of messages"
  it "should have a link for viewing each message"
  it "should have a link for deleting each message"
  it "should display attributes for each message" 
  it "should denote unread messages"
  it "should have a link for creating a new message"

end
