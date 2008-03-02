require File.dirname(__FILE__) + '/../../spec_helper'

describe "/messages/show" do

  before(:each) do
    render 'messages/show'
  end

  it "should show the subject" do
  	pending
  end
  
  it "should show the body" do
  	pending
  end
  
  describe "when showing a sent message" do
  
	  it "should show the sent date" do
	  	pending
	  end
	  
	  it "should contain a link to the receivers's org page" do
	  	pending
	  end
  
  end
  
  describe "when showing a received message" do
  
	  it "should show the received date" do
	  	pending
	  end
	  
	  it "should contain a link to the sender's org page" do
	  	pending
	  end
  
  end  
  
	it "should list the other messages in the thread (related messages)" do
		pending
	end
  
  it "should show the new message form with prepopulated recipient and subject" do
  	pending
  end
  
  it "should have a link to the message index page" do
  	pending
  end  
  
  it "should have a link to the sent messages page" do
  	pending
  end   
  
end
