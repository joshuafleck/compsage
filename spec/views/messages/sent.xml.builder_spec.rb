require File.dirname(__FILE__) + '/../../spec_helper'

describe "/messages/sent with xml" do
  before(:each) do
    render 'messages/sent.xml.builder'
  end
  
  it "should contain a list of messages and their attributes"
  
end
