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

  it "should be invalid without an email address when the email contact preference is specified" do
    @submission = ContactFormSubmission.new(VALID_ATTRIBUTES.except(:email))
    @submission.should_not be_valid
  end

  it "should be valid without an email address when the phone contact preference is specified" do
    @submission = ContactFormSubmission.new(VALID_ATTRIBUTES.except(:email).with(
      :contact_preference => 'phone',
      :phone => '5' * 10))

    @submission.should be_valid
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

  it "should be valid with a properly formatted phone number" do
    ['5555555555', '555-555-5555', '(555)-555-5555', '555.555.5555', '(555)444-3234'].each do |format|
      @submission = ContactFormSubmission.new(VALID_ATTRIBUTES.with(:phone => format))
      @submission.should be_valid
    end
  end

  it "should be invalid with an improperly formatted phone number" do
    ['565-2342', '234234', 'ASDF1234567890', '323-234-2341 ext 123'].each do |format|
      @submission = ContactFormSubmission.new(VALID_ATTRIBUTES.with(:phone => format))
      @submission.should_not be_valid
    end
  end

  it "should be invalid without a phone number with the phone contact preference specified" do
    @submission = ContactFormSubmission.new(VALID_ATTRIBUTES.with(:contact_preference => 'phone'))
    @submission.should_not be_valid
  end
end
