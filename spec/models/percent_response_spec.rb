require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PercentResponse do
  before(:each) do
    @response = PercentResponse.new
  end
  
  it "should save the response in numerical response" do
    @response.response = 123
    @response.numerical_response.should == 123
  end

  it "should strip out characters users may enter"  do
    @response.response = "%$1,234.00%"
    @response.numerical_response.to_i.should == 1234
  end

  it "should not strip out unusual characters" do
    @response.response = "1asdf2"
    @response.response_before_type_cast.should == "1asdf2"
  end

  it "should accept qualification" do
    PercentResponse.accepts_qualification.should be_true
  end
end
