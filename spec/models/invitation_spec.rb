require File.dirname(__FILE__) + '/../spec_helper'

describe Invitation do
  it "should have a type"
  it "should not allow an invalid type"
  it "should belong to an invitee"
  it "should belong to an inviter"
  it "should be able to be fetched be invitee_id"
  it "should be able to be fetched be inviter_id"
end
