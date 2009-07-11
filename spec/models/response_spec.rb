require File.dirname(__FILE__) + '/../spec_helper'

module ResponseSpecHelper
  def valid_response_attributes
    {
      :question => mock_model(Question, {:numerical_response? => false, :has_units? => false, :level => 0}),
      :response => "The response",
      :participation => mock_model(Participation)
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
    @response.attributes = valid_response_attributes.except(:question)
    @response.should have(1).errors_on(:question)
  end
  
  it 'should be invalid without a response' do 
    @response.attributes = valid_response_attributes.except(:response)
    @response.should_not be_valid
  end
  
  it 'should be invalid with a qualification but no response' do
    @response.attributes = valid_response_attributes.except(:response).with(:qualifications => 'something')
    @response.should_not be_valid
  end
  
  it 'should create a response of the proper type' do
    response = Response.new(:type => 'NumericalResponse')
    response.is_a?(NumericalResponse).should be_true
  end
end

describe Response, "with units" do
  include ResponseSpecHelper

  before(:each) do
    Response.stub!(:units).and_return(Units.new("format", {'Annually' => 1, 'Hourly' => 2080}, 'Annually'))
    @response = Response.new(valid_response_attributes)
  end

  it "should convert units before saving" do
    @response.numerical_response = 1
    @response.unit = "Hourly"
    @response.save!

    @response.numerical_response.should == 2080
  end

  it "should convert to user specified units when finding" do
    @response.numerical_response = 1
    @response.unit = "Hourly"
    @response.save!
    
    @response = Response.find(@response.id)
    @response.numerical_response.should == 1
  end
end

