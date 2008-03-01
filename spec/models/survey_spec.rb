require File.dirname(__FILE__) + '/../spec_helper'

describe Survey do
  it "should be valid"
  it "should belong to a sponsor"
  it "should have many and belong to many organizations"
  it "should have many discussions"
  it "should have many invitations"
  it "should have many questions"
  it "should have many responses"
  it "should require an end date to be specified"
  it "should not allow a title longer then 128 characters"
  
end
