require File.dirname(__FILE__) + '/../spec_helper'

describe Participation do
  before(:each) do
    @participation = Participation.new
  end  
  
  it "should be valid" do
    @participation.should be_valid
  end
  
  it "should belong to a survey" do
  	Participation.reflect_on_association(:survey).should_not be_nil
  end
  
  it "should belong to a participant" do
  	Participation.reflect_on_association(:participant).should_not be_nil
  end
  
  it "should have many responses" do
    Participation.reflect_on_association(:participant).should_not be_nil
  end
end