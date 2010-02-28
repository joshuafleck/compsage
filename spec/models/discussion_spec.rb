require File.dirname(__FILE__) + '/../spec_helper'

module DiscussionSpecHelper

  def valid_discussion_attributes
    {
      :survey => survey_mock,
      :responder => Factory(:organization),
      :subject => 'Discussion Title',
      :body => 'Discussion Body'
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
  
  it "should not allow a subject greater then 128 characters" do
    @discussion.attributes = valid_discussion_attributes.with(:subject => "0"*129)
    @discussion.should have(1).errors_on(:subject)
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
  
  it "should be invalid without a subject if it is the discussion root" do    
    @discussion.attributes = valid_discussion_attributes.except(:subject,:body)
    @discussion.should have(1).errors_on(:subject)
  end
  
  it "should be invalid without a body if it is a child" do   
    @discussion_parent = Discussion.create!(valid_discussion_attributes)
    @discussion.attributes = valid_discussion_attributes.except(:body).with(:parent_discussion_id => @discussion_parent.id)
    @discussion.should have(1).errors_on(:body)
  end  
    
  it "should assign discussion to the parent if this is a reply" do
    @survey = Factory.create(:survey)
    @discussion_parent = Discussion.create!(valid_discussion_attributes.with(:survey => @survey))
    @discussion = Discussion.create!(valid_discussion_attributes.with(:parent_discussion_id => @discussion_parent.id, :survey => @survey))
    @discussion_parent.children_count.should == 1
  end
  
  it "should sort discussions by created date" do
    @discussion_old = Discussion.create!(valid_discussion_attributes)
    @discussion_new = Discussion.create!(valid_discussion_attributes)
    @discussion_collection = [@discussion_new, @discussion_old]
    @discussion_collection.sort[0].should == @discussion_old
  end
end

describe Discussion, "that exists" do
  before do
    @discussion = Factory(:discussion)
  end

  it "should know if a comment is abusive" do
    @discussion.times_reported = Discussion::ABUSE_THRESHOLD
    @discussion.not_abuse?.should be_false
  end

  it "should know if a comment is not abusive" do
    @discussion.not_abuse?.should be_true
  end

  it "should know when the comment is a top-level comment" do
    @discussion.should be_topic
  end

  it "shoudl know when the comment is not a top level comment" do
    discussion_2 = Factory(:discussion, :survey => @discussion.survey)
    discussion_2.move_to_child_of(@discussion)
    discussion_2.should_not be_topic
  end
end
