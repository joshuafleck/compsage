require File.dirname(__FILE__) + '/../spec_helper'

module MessageSpecHelper

  def valid_Message_attributes
    {
      :title => 'Test Message',
      :body => 'Body of message',
      
    }
  end
end

describe Message do

  it "should know its related children" do
  #future code here pending review
  end
    
  it "should know its related root" do
  #future code here pending review
  end
  
  it "should know its related sender" do
  #future code here pending review
  end
    
  it "should know its related receiver" do
  #future code here pending review
  end  

end  
  
describe Message do

  include MessageSpecHelper

  before(:each) do
    @message = Message.new
  end
  
  it "should be sent by an organization" do
  #future code here pending review
  end
  
  it "should be received by an organization" do
  #future code here pending review
  end
  
  it "should not have a title longer then 128 characters" do
  #future code here pending review
  end
  
  it "should allow nil title" do
  #future code here pending review
  end  
  
end

describe Message do

  include MessageSpecHelper

  before(:each) do
    @message = Message.new
  end

  it "destroys related messages on destroy" do
  #future code here pending review
  end  

end 