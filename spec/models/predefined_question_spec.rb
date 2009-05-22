require File.dirname(__FILE__) + '/../spec_helper'

describe PredefinedQuestion do
  
  before do
    @predefined_question = Factory.build(:predefined_question, :name => "PQ 1") 
  end
  
  it "should build questions" do
    @predefined_question.save!
    @predefined_question.build_questions().size.should eql(1)
  end
  
end
