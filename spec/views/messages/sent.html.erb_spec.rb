require File.dirname(__FILE__) + '/../../spec_helper'

describe "/messages/sent" do

  before(:each) do
    render 'messages/sent'
  end
  
  it "should show the list of messages" do
  	pending
  end
  
  it "should allow pagination..." do
  	pending
  end
  
  it "should have a means for sorting the messages..." do
  	pending
  end
  
  it "should render the message subjects with a link to show the message" do
  	pending
  end
  
  it "should have a link for replying to each message" do
  	pending
  end
  
  it "should display the date/time the message was sent" do
  	pending
  end
  
  it "should display the recipient with a link to the recipient's page" do
  	pending
  end
  
  describe "when the organization is public" do
  
	  it "should have a link for creating a new message" do
  		pending
  	end
  
  end
  
  describe "when the organization is private" do
  
	  it "should have a disabled link for creating a new message" do
  		pending
 	 end
  
	  it "should have an explanation for why it cannot create a message" do
  		pending
 	 end
  
  end
  
  it "should have a link to the messages index page" do
  	pending
  end
  
end
