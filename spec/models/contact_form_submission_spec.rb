require File.dirname(__FILE__) + '/../spec_helper'

describe ContactFormSubmission do
  VALID_ATTRIBUTES = {:name => "Brian Terlson", :email => "brian.terlson@gmail.com", :message => "Cool stuff!"}

  it "should be valid" do
    @submission = ContactFormSubmission.new(VALID_ATTRIBUTES)
    @submission.should be_valid
  end

  it "should be invalid without a name" do
    @submission = ContactFormSubmission.new(VALID_ATTRIBUTES.except(:name))
    @submission.should_not be_valid
  end

  it "should be invalid without an email address" do
    @submission = ContactFormSubmission.new(VALID_ATTRIBUTES.except(:email))
    @submission.should_not be_valid
  end

  it "should be invalid with a malformed email address" do
    @submission = ContactFormSubmission.new(VALID_ATTRIBUTES.with(:email => "hurr"))
    @submission.should_not be_valid
  end

  it "should be invalid without a message" do
    @submission = ContactFormSubmission.new(VALID_ATTRIBUTES.except(:message))
    @submission.should_not be_valid
  end

  it "should default to email contact preference" do
    @submission = ContactFormSubmission.new(VALID_ATTRIBUTES)
    @submission.contact_preference.should == "email"
  end
end
