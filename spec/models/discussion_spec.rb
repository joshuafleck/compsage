require File.dirname(__FILE__) + '/../spec_helper'
describe Discussion do
  it "should be valid"
  it "should belong to a survey"
  it "should belong to an organization"
  it "should require a parent_id"
  it "should act as a nested set"
  it "should be in the scope of a survey via survey_id"
  it "should be invalid without a survey"
  
  it "should not allow a title greater then 128 character"
end