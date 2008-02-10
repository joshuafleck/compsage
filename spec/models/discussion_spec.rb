require File.dirname(__FILE__) + '/../spec_helper'
describe Discussion do
  it "should belong to a survey"
  it "should belong to an organization"
  it "should require a parent_id"
  it "should act as a nested set"
  it "should be in the scope of a survey via survey_id"

end