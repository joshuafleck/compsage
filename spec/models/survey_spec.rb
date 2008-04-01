require File.dirname(__FILE__) + '/../spec_helper'

describe Survey do
  it "should be valid"
  it "should belong to a sponsor"
  #it "should have many and belong to many organizations" - I'm not sure this spec is valid since we are doing away with the many to many table here -JF
  it "should have many discussions"
  it "should have many invitations"
  it "should have many external invitations"
  it "should have many questions"
  it "should have many responses"
  it "should require an end date to be specified"
  it "should not allow a title longer then 128 characters"
  
end
