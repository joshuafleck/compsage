require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/new" do

  before(:each) do
    # TODO: Implement the spec.
    assigns[:predefined_questions] = []
    
    render 'surveys/new'
  end
  
  it "should render the new surveys form" do
     response.should have_tag("form")
  end
  
  it "should render the survey questions form" do
    pending
  end
  
  it "should have a submit button" do
    response.should have_tag("input[type=submit]")
  end
  
  it "should have a cancel link" do
    response.should have_tag("a[href=#{surveys_path}]", "Cancel")
  end

end