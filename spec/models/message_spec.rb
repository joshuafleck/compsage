require File.dirname(__FILE__) + '/../spec_helper'

module MessageSpecHelper

  def valid_message_attributes
    {
      :title => 'Test Message',
      :body => 'Body of message',
      
    }
  end
end

describe Message, "that does not exist" do

  it "has many children" do
  #future code here pending review
  end
    
  it "has one parent" do
  #future code here pending review
  end
  
  it "has one sender" do
  #future code here pending review
  end
    
  it "has one receiver" do
  #future code here pending review
  end  

end  
  
describe Message, "that does exist" do

  include MessageSpecHelper

  before(:each) do
    @message = Message.new
  end

  it "should be valid on create" do
  #future code here pending review
  end  
    
  it "should be sent by an organization" do
  #future code here pending review
  end
  
  it "should be received by an organization" do
  #future code here pending review
  end
  
  it "should be invalid with a title longer than 128 characters" do
  #future code here pending review
  end
  
  it "should allow nil title" do
  #future code here pending review
  end  

end
