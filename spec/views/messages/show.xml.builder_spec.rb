require File.dirname(__FILE__) + '/../../spec_helper'

describe "/messages/show with xml" do
  before(:each) do
    render 'messages/show.xml.builder'
  end
  
  it "should contain the subject"
  it "should contain the body"
  it "should contain the creation date"
  it "should contain the sender's id"
  it "should contain the read flag"
  it "should contain the root message id"
  it "should contain a list of related messages with attibutes"
  
end
