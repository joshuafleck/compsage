require File.dirname(__FILE__) + '/../../spec_helper'

describe "/messages/index" do

  before(:each) do
    render 'messages/index'
  end

  it "should render the list of messages"
  it "should render the message subjects with a link to show the message"
  it "should have a link for deleting each message"
  it "should have a link for replying to each message"
  it "should display attributes for each message including the created_at date and sender with a link to thier org page" 
  it "should denote unread messages"
  it "should have a link for creating a new message if the organization is public"
  it "should have a disabled link for creating a new message if the organization is public"
  it "should have a link to the sent messages page"

end
