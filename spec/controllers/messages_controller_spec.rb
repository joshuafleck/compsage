require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController, "#route_for" do

  it "should map { :controller => 'messages', :action => 'index' } to /messages" do
    #route_for(:controller => "messages", :action => "index").should == "/messages"
  end

  it "should map { :controller => 'messages', :action => 'new' } to /messages/new" do
    #route_for(:controller => "messages", :action => "new").should == "/messages/new"
  end

  it "should map { :controller => 'messages', :action => 'show', :id => 1 } to /messages/1" do
    #route_for(:controller => "messages", :action => "show", :id => 1).should == "/messages/1"
  end

  it "should map { :controller => 'messages', :action => 'destroy', :id => 1} to /messages/1" do
    #route_for(:controller => "messages", :action => "destroy", :id => 1).should == "/messages/1"
  end

  it "should map { :controller => 'messages', :action => 'sent'} to /messages/sent" do
    #route_for(:controller => "messages", :action => "sent").should == "/messages/sent"
    #see :collection and :member info in Resources rubydoc
  end
 
end

describe MessagesController, " handling GET /messages" do
  it "should be successful"
  it "should render index template"
  it "should find all received messages"
  it "should assign the found messages for the view"
end

describe MessagesController, " handling GET /messages.xml" do
  it "should be successful"
  it "should find all received messages"
  it "should render the found messages as XML"
end

describe MessagesController, " handling GET /messages/1" do
  it "should be successful"
  it "should find the message if the org is the sender or receiver"
  it "should find the related messages if the org is the sender or receiver?"
  it "should set the read status to true if the receiver is retrieving the message"
  it "should flash an error and redirect to the message index if the org is not the sender or receiver"
  it "should render the show template"
  it "should render the new template and prepopulate the receiver, subject, and root message"
  it "should assign the found message (and related messages)? to the view"
end

describe MessagesController, " handling GET /messages/1.xml" do
  it "should be successful"
  it "should set the read status to true if the receiver is retrieving the message"
  it "should find the message if the org is the sender or receiver"
  it "should return an error if the org is not the sender or receiver"
  it "should find the related messages if the org is the sender or receiver? and render them in the xml"
  it "should render the found message as XML"
end

describe MessagesController, " handling GET /messages/new" do
  it "should be successful"
  it "should render new template"
end

describe MessagesController, " handling POST /messages" do
  it "should create a new message by owner"
  it "should flash a message regarding the success of the create"
  it "should redirect to the new message"
end

describe MessagesController, " handling DELETE /messages/1" do
  it "should find the message requested"
  it "should destroy the message requested if the org is the receiver of the message"
  it "should return an error if the org is not the receiver of the message"
  it "should flash a message regarding the success of the delete"
  it "should redirect to the message index"
end

describe MessagesController, " handling GET /messages/sent" do
  it "should be successful"
  it "should render index template"
  it "should find all sent messages"
  it "should assign the found messages for the view"
end

describe MessagesController, " handling GET /messages/sent.xml" do
  it "should be successful"
  it "should find all sent messages"
  it "should render the found messages as XML"
end

