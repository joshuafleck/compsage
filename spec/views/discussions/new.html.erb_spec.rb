require File.dirname(__FILE__) + '/../../spec_helper'

describe "discussions/new" do

  before(:each) do
    
    @parent_discussion = stub_model(Discussion)      
    @discussion = stub_model(Discussion)
    @survey = stub_model(Survey)
    
    assigns[:survey] = @survey
    assigns[:discussion] = @discussion
    assigns[:parent_discussion] = @parent_discussion
    
    render 'discussions/new'
  end
  
  it "should render the new form" do
    response.should have_tag("form")
  end
  
  it "should have a submit button" do
    response.should have_tag("input[type=submit]")
  end
  
  it "should have a cancel button" do
    response.should have_tag("a[href=#{survey_discussions_path(@survey)}]", "Cancel")
  end
  
  it "should have a parameter for the parent discussion id if the parent exists" do
    response.should have_tag("input[id=discussion_parent_discussion_id]")
  end
  
  it "should allow the input of a topic" do
    response.should have_tag("input[id=discussion_subject]")
  end
end

describe "discussions/new with new discussion topic" do

  before(:each) do
         
    @discussion = stub_model(Discussion)
    
    assigns[:discussion] = @discussion        
    assigns[:survey] = @survey
        
    render 'discussions/new'
  end
  
  it "should not have a parameter for the parent discussion id if the parent does not exist" do
    response.should_not have_tag("input[id=discussion_parent_discussion_id]")
  end
  
end
