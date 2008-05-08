require File.dirname(__FILE__) + '/../../spec_helper'

describe "discussions/edit" do
  
  before(:each) do
    
    @discussion = mock_model(Discussion,
      :title => "Discussion title",
      :body => "Discussion Body")
      
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
    response.should have_tag("a[href=#{survey_discussions_path(@survey)}]", "Cancel")
  end
end
