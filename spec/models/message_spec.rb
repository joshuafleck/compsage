require File.dirname(__FILE__) + '/../spec_helper'

module MessageSpecHelper

	def message_mock 
		mock_model(
				Message, 
      	:title => 'Test Message',
      	:body => 'Body of message',
      	:sender => organization_mock,
      	:receiver => organization_mock,
      	:root => nil)
	end

  def valid_message_attributes
    {
      :title => 'Test Message',
      :body => 'Body of message',
      :sender => organization_mock,
      :receiver => organization_mock,
      :root => message_mock
    }
  end

end

describe Message, "that does not exist" do

  include MessageSpecHelper

  before(:each) do
    @message = Message.new
  	@message.attributes = valid_message_attributes
  end
  	
  it "should have many child messages" do
  	Message.reflect_on_association(:messages).should_not be_nil
  end
    
  it "should have one parent message" do
  	Message.reflect_on_association(:root).should_not be_nil
  end
  
  it "should have one sender" do
  	Message.reflect_on_association(:sender).should_not be_nil
  end
    
  it "should have one receiver" do
  	Message.reflect_on_association(:receiver).should_not be_nil
  end  
    
  it "should be invalid without a sender" do
  pending
  end
  
  it "should be invalid without a receiver" do
  pending
  end
  
  it "should be invalid with a title longer than 128 characters" do
  pending
  end
 
  it "should be valid with no title" do
  pending
  end  
  
  it "should be invalid when title and body are both missing" do
  	pending
  end

  it "should be valid" do
		@message.should be_valid
  end  
 
end  
  
describe Message, "that does exist" do

  include MessageSpecHelper

  before(:each) do
    @message = Message.new
  	@message.attributes = valid_message_attributes
  	@message.save
  end
  
  after(:each) do
  	@message.destroy
  end  

end
