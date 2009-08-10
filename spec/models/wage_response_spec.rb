require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WageResponse do
  before(:each) do
    @response = WageResponse.new
  end
  
  it "should save the response in numerical response" do
    @response.response = 123
    @response.numerical_response.should == 12300
  end

  it "should strip out characters users may enter"  do
    @response.response = "%$1,234.00%"
    @response.numerical_response.to_i.should == 123400
  end

  it "should not strip out unusual characters" do
    @response.response = "1asdf2"
    @response.response_before_type_cast.should == "1asdf2"
  end

  it "should accept comment" do
    WageResponse.accepts_comment.should be_true
  end

  it "should have some units" do
    WageResponse.units.should_not be_nil
  end

  it "should convert answers to cents" do
    @response.response = "$100.00"
    @response.numerical_response.should == 10000
  end

end

describe Response, "with units" do
  before(:each) do
    @response = WageResponse.new(:question => mock_model(Question, {:numerical_response? => true, :has_units? => false, :level => 0}),
      :participation => mock_model(Participation))
  end

  it "should convert units before saving" do
    @response.response = 1
    @response.unit = "Hourly"
    @response.save!

    @response.response.should == 2080
  end

  it "should convert to user specified units when finding" do
    @response.response = 1
    @response.unit = "Hourly"
    @response.save!
    
    @response = Response.find(@response.id)
    @response.response.should == 1
  end
end

