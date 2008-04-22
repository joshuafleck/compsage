require File.dirname(__FILE__) + '/../spec_helper'

module DiscussionSpecHelper

  def valid_discussion_attributes
    {
      :survey => survey_mock,
      :organization => organization_mock,
      :title => 'Discussion Title'
    }
  end
  
end

describe Discussion do

  include DiscussionSpecHelper

  before(:each) do
    @discussion = Discussion.new
  end  
  
  it "should be valid" do
  	@discussion.attributes = valid_discussion_attributes 
  	#@discussion.attributes.each_pair {|key, value| puts "#{key} is #{value}" }
  	#puts @discussion.errors.full_messages
    @discussion.should be_valid
  end
  
  it "should belong to a survey" do
  	Discussion.reflect_on_association(:survey).should_not be_nil
  end
  
  it "should belong to an organization" do
  	Discussion.reflect_on_association(:organization).should_not be_nil
  end
  
  it "should belong to an external invitation" do
  	Discussion.reflect_on_association(:external_survey_invitation).should_not be_nil
  end
  
  it "should be invalid without a survey" do
  	@discussion.attributes = valid_discussion_attributes.except(:survey)
    @discussion.should have(1).errors_on(:survey)
  end
  
  it "should not allow a title greater then 128 characters" do
  	@discussion.attributes = valid_discussion_attributes.with(:title => "0"*129)
    @discussion.should have(1).errors_on(:title)
  end
  
  it "should not all the body to be greater then 1024 characters" do
  	@discussion.attributes = valid_discussion_attributes.with(:body => "0"*1025)
    @discussion.should have(1).errors_on(:body)
  end
  
  it "should have a default value of zero for times reported" do
	  @discussion.attributes = valid_discussion_attributes
	  @discussion.save
  	@discussion.times_reported.should equal(0)
  end
  
  it "should be invalid without one of the following: organization, external_survey_invitation" do  	
  	@discussion.attributes = valid_discussion_attributes.except(:organization,:external_survey_invitation)
  	#@discussion.attributes.each_pair {|key, value| puts "#{key} is #{value}" }
    @discussion.should have(1).errors_on(:external_survey_invitation)
    @discussion.should have(1).errors_on(:organization)
  end
  
  it "should be invalid without one of the following: title, body" do  	
  	@discussion.attributes = valid_discussion_attributes.except(:title,:body)
    @discussion.should have(1).errors_on(:title)
    @discussion.should have(1).errors_on(:body)
  end
end
