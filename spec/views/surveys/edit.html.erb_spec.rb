require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/edit" do

  before(:each) do
    assigns[:predefined_questions] = []
    render 'surveys/edit'
  end
  
  it "should render the edit form" do
    response.should have_tag("form")
  end
  it "should render the surveys questions" do
    pending
  end
  it "should have a submit button" do
    response.should have_tag("input[type=submit]")
  end
  it "should have a cancel link" do
    response.should have_tag("a[href=#{surveys_path}]", "Cancel")
  end

end