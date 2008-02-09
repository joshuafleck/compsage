require File.dirname(__FILE__) + '/../spec_helper'

describe Survey do
  it "should belong to a sponsor"
  it "should have many and belong to many organizations"
  it "should have many discussions"
  it "should have many survey_invitations"
  it "requires a title"
end

describe Survey, "fetch by sponsor" do
  
end
