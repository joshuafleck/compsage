require File.dirname(__FILE__) + '/../spec_helper'

module ResponseSpecHelper

  def valid_response_attributes
    {
      :question => mock_model(Question, {}),
      :textual_response => 'The response',
      :numerical_response => 1.0
    }
  end
  
end

describe Response do

  include ResponseSpecHelper

  before(:each) do
    @response = Response.new
  end
  
  # test that the associations are here
  
  it 'should be valid' do
  	@response.attributes = valid_response_attributes
  	@response.should be_valid
  end
  
  it 'should belong to a participation' do
  	Response.reflect_on_association(:participation).should_not be_nil
  end
  
  it 'should belong to a question' do
  	Response.reflect_on_association(:question).should_not be_nil
  end
  
  it 'should be invalid without a question' do
  	@response.attributes = valid_response_attributes.except(:question)
    @response.should have(1).errors_on(:question)
  end
  
  it 'should be invalid without one of the following: textual_response, numerical_response'  do 	
  	@response.attributes = valid_response_attributes.except(:textual_response,:numerical_response)
    @response.should have(1).errors_on(:textual_response)
    @response.should have(1).errors_on(:numerical_response)
  end
  
end


describe Response, "to question with numerical response" do

  include ResponseSpecHelper

  before(:each) do
    @response = Response.new
  end
    
  it "should return a numerical response" do
  	@response.attributes = valid_response_attributes.with(:question => mock_model(Question, :numerical_response? => true))
  	@response.get_response.should eql(valid_response_attributes[:numerical_response])
  end
  
end

describe Response, "to question with text-based response" do

  include ResponseSpecHelper

  before(:each) do
    @response = Response.new
  end
    
  it "should return a textual response" do
  	@response.attributes = valid_response_attributes.with(:question => mock_model(Question, :numerical_response? => false))
  	@response.get_response.should eql(valid_response_attributes[:textual_response])
  end
  
end

