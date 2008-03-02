require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController, "when an illegal action has been attempted", :shared => true do

	describe "when the request is XML" do
	 	
	 		it "should return an error" do
	 			pending	 		
	 		end
	 	
	 	end
	 	
	 	describe "when the request is HTML" do
	 	
		 	it "should redirect to the message index page" do
		 		pending
		 	end
		 	
		 	it "should flash an error message" do
		 		pending
		 	end
	 	
	 	end

end

describe MessagesController, "#route_for" do

  it "should map { :controller => 'messages', :action => 'index' } to /messages" do
    #route_for(:controller => "messages", :action => "index").should == "/messages"
    pending
  end

  it "should map { :controller => 'messages', :action => 'new' } to /messages/new" do
    #route_for(:controller => "messages", :action => "new").should == "/messages/new"
    pending
  end

  it "should map { :controller => 'messages', :action => 'show', :id => 1 } to /messages/1" do
    #route_for(:controller => "messages", :action => "show", :id => 1).should == "/messages/1"
    pending
  end

  it "should map { :controller => 'messages', :action => 'destroy', :id => 1} to /messages/1" do
    #route_for(:controller => "messages", :action => "destroy", :id => 1).should == "/messages/1"
    pending
  end

  it "should map { :controller => 'messages', :action => 'sent'} to /messages/sent" do
    #route_for(:controller => "messages", :action => "sent").should == "/messages/sent"
    #see :collection and :member info in Resources rubydoc
    pending
  end
 
end

describe MessagesController, " handling GET /messages" do

  it "should be successful" do
  	pending
  end
  
  it "should render index template" do
  	pending
  end
  
  it "should find all received messages" do
  	pending
  end
  
  it "should assign the found messages for the view" do
  	pending
  end
  
  it "should support sorting..." do
  	pending
  end
    
  it "should support pagination..." do
  	pending
  end
  
end

describe MessagesController, " handling GET /messages.xml" do

  it "should be successful" do
  	pending
  end
  
  it "should find all received messages" do
  	pending
  end
  
  it "should render the found messages as XML" do
  	pending
  end
  
end

describe MessagesController, " handling GET /messages/1" do

  it "should be successful" do
  	pending
  end
  
  it "should find the message" do
  	pending
  end
    
  describe "when the organization is not the sender or receiver" do
  
		it_should_behave_like "MessagesController when an illegal action has been attempted"
  
  end

  it "should find the other messages in the thread (related messages)" do
  	pending
  end
  
  it "should assign the message to the view" do
  	pending
  end
  
  it "should assign the related messages to the view" do
  	pending
  end

  it "should set the read status to true if the receiver is retrieving the message" do
  	pending
  end

  it "should render the show template" do
  	pending
  end
  
  it "should render the new template" do
  	pending
  end

end

describe MessagesController, " handling GET /messages/1.xml" do

  it "should be successful" do
  	pending
  end
  
  it "should find the message" do
  	pending
  end
    
  describe "when the organization is not the sender or receiver" do
  
		it_should_behave_like "MessagesController when an illegal action has been attempted"
  
  end

  it "should find the other messages in the thread (related messages)" do
  	pending
  end
  
  it "should render the found message as XML" do
  	pending
  end
  
  it "should render the related messages as XML" do
  	pending
  end  
  
end

describe MessagesController, " handling GET /messages/new" do

  it "should be successful" do
  	pending
  end
    
  describe "when the organization is private" do
  
		it_should_behave_like "MessagesController when an illegal action has been attempted"
  
  end

  it "should render new template" do
  	pending
  end
  
end

describe MessagesController, " handling POST /messages" do
    
  describe "when the organization is private" do
  
		it_should_behave_like "MessagesController when an illegal action has been attempted"
  
  end

  it "should create a new message" do
  	pending
  end

  describe "when the request is XML" do
  
  	it "should return a response regarding the success of the action" do
  		pending
  	end
  
  end
  
  describe "when the request is HTML" do
  
	  it "should redirect to the show message view" do
	    pending    
	  end
	  
	  it "should flash a message regarding the success of the creation" do
	    pending    
	  end
	  
  end
  
end

describe MessagesController, " handling DELETE /messages/1" do

  it "should find the message requested" do
  	pending
  end
  
  describe "when the organization is not the reciever" do
  
		it_should_behave_like "MessagesController when an illegal action has been attempted"
  
  end
  
  it "should destroy the message" do
  	pending
  end

  describe "when the request is XML" do
  
  	it "should return a response regarding the success of the action" do
  		pending
  	end
  
  end
  
  describe "when the request is HTML" do
  
	  it "should redirect to the message index" do
	    pending    
	  end
	  
	  it "should flash a message regarding the success of the delete" do
	    pending    
	  end
	  
  end

end

describe MessagesController, " handling GET /messages/sent" do

  it "should be successful" do
  	pending
  end
  
  it "should render index template" do
  	pending
  end
  
  it "should find all sent messages" do
  	pending
  end
  
  it "should assign the found messages for the view" do
  	pending
  end
  
  it "should support sorting..." do
  	pending
  end
    
  it "should support pagination..." do
  	pending
  end
  
end

describe MessagesController, " handling GET /messages/sent.xml" do

  it "should be successful" do
  	pending
  end
  
  it "should find all sent messages" do
  	pending
  end
  
  it "should render the found messages as XML" do
  	pending
  end
  
end

