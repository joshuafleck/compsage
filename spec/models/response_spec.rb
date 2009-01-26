require File.dirname(__FILE__) + '/../spec_helper'

module ResponseSpecHelper

  def valid_numerical_response_attributes
    {
      :question => mock_model(Question, {:numerical_response? => true, :has_units? => false}),
      :response => 1.0
    }
  end
  
  def valid_textual_response_attributes
    {
      :question => mock_model(Question, {:numerical_response? => false, :has_units? => false}),
      :response => "The response"
    }
  end

  def valid_wage_response_attributes
    {
      :question => mock_model(Question, {:numerical_response? => true, :has_units? => true}),
      :response => 1.0,
      :units => "Hourly",
    }
  end
end

describe Response do

  include ResponseSpecHelper

  before(:each) do
    @response = Response.new
  end
  
  it 'should belong to a participation' do
  	Response.reflect_on_association(:participation).should_not be_nil
  end
  
  it 'should belong to a question' do
  	Response.reflect_on_association(:question).should_not be_nil
  end
  
  it 'should be invalid without a question' do
  	@response.attributes = valid_numerical_response_attributes.except(:question)
    @response.should have(1).errors_on(:question)
  end
  
  it 'should be invalid without a response' do 
  	@response.attributes = valid_numerical_response_attributes.except(:response)
  	@response.should_not be_valid
  end
  
  it 'should be invalid with a qualification but no response' do
    @response.attributes = valid_numerical_response_attributes.except(:response).with(:qualifications => 'something')
    @response.should_not be_valid
  end
  
end


describe Response, "to question with numerical response" do

  include ResponseSpecHelper

  before(:each) do
    @response = Response.new
    @response.stub!(:question).and_return(valid_numerical_response_attributes[:question])
  end
    
  it 'should be valid' do
  	@response.attributes = valid_numerical_response_attributes
  	@response.should be_valid
  end
  
  it "should return a numerical response" do
  	@response.attributes = valid_numerical_response_attributes 
  	@response.response.should == valid_numerical_response_attributes[:response] 
  end
  
end

describe Response, "to question with text-based response" do

  include ResponseSpecHelper

  before(:each) do
    @response = Response.new
    @response.stub!(:question).and_return(valid_textual_response_attributes[:question])
  end
   
  it 'should be valid' do
    @response.attributes = valid_textual_response_attributes
    @response.should be_valid
    
  end

  it "should return a textual response" do
  	@response.attributes = valid_textual_response_attributes
  	@response.response.should == valid_textual_response_attributes[:response]
  end
  
end

describe Response, "to a question with units" do
  include ResponseSpecHelper

  before do
    @response = Response.new
    @response.stub!(:question).and_return(valid_wage_response_attributes[:question])
  end

  it 'should require units to be specified' do
    @response.attributes = valid_wage_response_attributes.except(:units)
    @response.should_not be_valid
  end
end
