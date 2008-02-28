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
	
  it "has many children" do
  	Message.reflect_on_association(:messages).should_not be_nil
  end
    
  it "has one parent" do
  	Message.reflect_on_association(:root).should_not be_nil
  end
  
  it "has one sender" do
  	Message.reflect_on_association(:sender).should_not be_nil
  end
    
  it "has one receiver" do
  	Message.reflect_on_association(:receiver).should_not be_nil
  end  
    
  it "should be invalid without a sending organization" do
  #future code here pending review
  end
  
  it "should be invalid without a receiving organization" do
  #future code here pending review
  end
  
  it "should be invalid with a title longer than 128 characters" do
  #future code here pending review
  end
 
  it "should be valid with a nil title" do
  #future code here pending review
  end  
 
end  
  
describe Message, "that does exist" do

  include MessageSpecHelper

  before(:each) do
    @message = Message.new
  end

  it "should be valid on create" do
  	@message.attributes = valid_message_attributes
		@message.should be_valid
  end  

end
