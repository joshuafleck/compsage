require File.dirname(__FILE__) + '/../spec_helper'

module DiscussionSpecHelper

  def valid_discussion_attributes
    {
      :survey => survey_mock,
      :responder => organization_mock,
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
    @discussion.should be_valid
  end
  
  it "should belong to a survey" do
  	Discussion.reflect_on_association(:survey).should_not be_nil
  end
  
  it "should belong to a responder" do
  	Discussion.reflect_on_association(:responder).should_not be_nil
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
  
  it "should be invalid without a responder" do  	
  	@discussion.attributes = valid_discussion_attributes.except(:responder)
    @discussion.should have(1).errors_on(:responder)
  end
  
  it "should be invalid without one of the following: title, body" do  	
  	@discussion.attributes = valid_discussion_attributes.except(:title,:body)
    @discussion.should have(1).errors_on(:title)
    @discussion.should have(1).errors_on(:body)
  end
    
  it "should assign discussion to the parent if this is a reply" do
    @discussion_parent = Discussion.create!(valid_discussion_attributes)
    @discussion = Discussion.create!(valid_discussion_attributes.with(:parent_discussion_id => @discussion_parent.id, :survey => @discussion_parent.survey ))
    @discussion_parent.children_count.should equal(1)
  end
  
  it "should sort discussions by created date" do
    @discussion_old = Discussion.create!(valid_discussion_attributes)
    @discussion_new = Discussion.create!(valid_discussion_attributes)
    @discussion_collection = [@discussion_new, @discussion_old]
    @discussion_collection.sort[0].should eql(@discussion_old)
  end
  
end
