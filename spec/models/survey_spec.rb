require File.dirname(__FILE__) + '/../spec_helper'

describe Survey, "that does not exist" do
  it "should be valid"
  it "should belong to a sponsor"
  it "should have many and belong to many organizations"
  it "should have many discussions"
  it "should have many survey_invitations"
  
end

describe Survey, "that does exists" do
  it "should not allow a title longer then 128 characters"
end
