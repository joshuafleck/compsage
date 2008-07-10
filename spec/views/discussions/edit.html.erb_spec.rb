require File.dirname(__FILE__) + '/../../spec_helper'

describe "discussions/edit" do
  
  before(:each) do
    
    @discussion = mock_model(Discussion,
      :subject => "Discussion subject",
      :body => "Discussion Body",
      :root? => true)
      
    assigns[:discussion] = @discussion
        
    template.stub!(:survey).and_return(mock_model(Survey))
    
    render 'discussions/edit'
  end
  
  it "should render the edit form" do
    response.should have_tag("form")
  end
  
  it "should have a submit button" do
    response.should have_tag("input[type=submit]")
  end
  
  it "should have a cancel button" do
    response.should have_tag("a[href=#{survey_path(@survey)}]", "Cancel")
  end
  
  it "should allow the edit of a subject if the discussion is a root" do
    response.should have_tag("input[id=discussion_subject]")
  end
end

describe "discussions/edit" do
  
  before(:each) do
    
    @discussion = mock_model(Discussion,
      :subject => "Discussion subject",
      :body => "Discussion Body",
      :root? => false)
      
    assigns[:discussion] = @discussion
        
    template.stub!(:survey).and_return(mock_model(Survey))
    
    render 'discussions/edit'
  end
  
  it "should not allow the edit of a subject if the discussion is not a root" do
    response.should_not have_tag("input[id=discussion_subject]")
  end
end
