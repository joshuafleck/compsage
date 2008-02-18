require File.dirname(__FILE__) + '/../../spec_helper'

describe "/messages/index with xml" do
  before(:each) do
    render 'messages/index.xml.builder'
  end
  
  it "should contain a list of messages and their attributes"
  
end
