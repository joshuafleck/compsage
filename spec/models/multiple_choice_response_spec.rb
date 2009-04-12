require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MultipleChoiceResponse do
  before(:each) do
    @response = MultipleChoiceResponse.new
  end

  it "should save the response in numerical response" do
    @response.response = 1
    @response.numerical_response.should == 1
  end
end
