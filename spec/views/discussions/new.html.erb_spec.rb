require File.dirname(__FILE__) + '/../../spec_helper'

describe "discussions/new" do

  before(:each) do
    
    @parent_discussion = mock_model(Discussion,
      :subject => "Discussion subject",
      :body => "Discussion Body",
      :root? => true)      
    @discussion = mock_model(Discussion,
      :subject => "Child subject",
      :body => "Child body")
    @survey = mock_model(Survey, :id => "1")
    
    assigns[:parent_discussion] = @parent_discussion
    assigns[:discussion] = @discussion        
    assigns[:survey] = @survey
    
    #template.stub!(:survey).and_return(mock_model(Survey))
        
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
  
  it "should have a paramter for the parent discussion id if the parent exists" do
    response.should have_tag("input[id=parent_discussion_id]")
  end
  
  it "should not allow the input of a topic if the parent exists" do
    response.should_not have_tag("input[id=discussion_subject]")
  end
end

describe "discussions/new" do

  before(:each) do
         
    @discussion = mock_model(Discussion,
      :subject => "Child subject",
      :body => "Child body")
    @survey = mock_model(Survey, :id => "1")
    
    assigns[:discussion] = @discussion        
    assigns[:survey] = @survey
        
    render 'discussions/new'
  end
  
  it "should not have a parameter for the parent discussion id if the parent does not exist" do
    response.should_not have_tag("input[id=parent_discussion_id]")
  end
  
  it "should allow the input of a topic if the parent does not exist" do
    response.should have_tag("input[id=discussion_subject]")
  end
end
