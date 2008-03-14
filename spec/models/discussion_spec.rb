require File.dirname(__FILE__) + '/../spec_helper'
describe Discussion do
  it "should be valid"
  it "should belong to a survey"
  it "should belong to an organization"
  it "the scope should be specified"
  it "should be invalid without a survey"
  it "should not allow a title greater then 128 characters"
  it "should not all the body to be greater then 1024 characters"
  it "should have a default value of zero for times reported"
end