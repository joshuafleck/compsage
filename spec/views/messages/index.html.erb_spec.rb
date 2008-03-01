require File.dirname(__FILE__) + '/../../spec_helper'

describe "/messages/index" do

  before(:each) do
    render 'messages/index'
  end

  it "should show the list of messages"
  it "should allow pagination..."
  it "should have a means for sorting the messages..."
  it "should render the message subjects with a link to show the message"
  it "should have a link for deleting each message"
  it "should have a link for replying to each message"
  it "should display the date/time the message was received"
  it "should display the sender with a link to the sender's page"
  it "should denote unread messages"
  describe "when the organization is public" do
	  it "should have a link for creating a new message"
  end
  describe "when the organization is private" do
	  it "should have a disabled link for creating a new message"
	  it "should have an explanation for why it cannot create a message"
  end
  it "should have a link to the sent messages page"

end
