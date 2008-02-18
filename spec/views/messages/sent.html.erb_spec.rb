require File.dirname(__FILE__) + '/../../spec_helper'

describe "/messages/sent" do

  before(:each) do
    render 'messages/sent'
  end
  
  it "should render the list of messages"
  it "should render the message subjects with a link to show the message"
  it "should display attributes for each message including the created_at date and receiver with a link to their org page" 
  it "should have a link to the inbox (index) page"

end
