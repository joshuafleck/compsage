require File.dirname(__FILE__) + '/../../spec_helper'

describe "/survey_invitations/index" do

  before(:each) do
    render 'survey_invitations/index'
  end
  
  it "should render the a list of invitations for a survey"
  it "should have a form that redirects to a survey"
  it "should have an accept delete button for each invitation"
  it "should have a button to create a new survey invitation"
end