require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TextualResponse do
  before(:each) do
    @textual_response = TextualResponse.new
  end

  it "should save the response in textual_response" do
    @textual_response.response = "rampage"
    @textual_response.textual_response.should == "rampage"
  end

  it "should not accept comment" do
    TextualResponse.accepts_comment.should be_false
  end
end
