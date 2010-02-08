require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
# This is not inherited from ActiveRecord, so the spec will be slightly different

it "should find add valid members to valid member collection"
it "should add invalid members to invalid member list"
it "should remove exists organizations if destroy parameter is set"
it "should successfully create a new member from a csv row"
it "should successfully update an existing member from a csv row"
it "should matching industry codes"
it "should give null for invalid industry codes"
it "should find exists members by any matchable attribute"
it "should raise No Import File if given bad file"
it "should raise invalid row with a bad input file row"
