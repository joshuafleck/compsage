require File.dirname(__FILE__) + '/../../spec_helper'

describe "/survey_invitations/new" do

  before(:each) do
    render 'survey_invitations/new'
  end
  
  it "should render the survey invitation attributes"
  it "should render the survey title"
  it "should have a means to add an organization"
  it "should have a means to remove an organization"
  it "should have a means for adding external organizations"
  it "should have a submit button"
  it "should have a cancel button"

end