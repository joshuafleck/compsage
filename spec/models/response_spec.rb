require File.dirname(__FILE__) + '/../spec_helper'

describe Response do
  before(:each) do
    @response = Response.new
  end
  # test that the associations are here
  
  it 'should be valid'
  
  it 'should be invalid without a question'
  
  it 'should be invalid without an organization'
  
  it 'should be invalid without some response'
  
end


describe Response, "to question with options" do
  
  it "should return a numerical response"
  
end

describe Response, "to question with text based response" do
  
  it "should return a textual response"
  
end

describe Response, "to quesiton with fill-in numerical response" do
  
  it "should return a numerical response"

end