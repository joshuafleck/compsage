require File.dirname(__FILE__) + '/../../spec_helper'

describe "/survey_invitations/index" do

  before(:each) do
    render 'survey_invitations/index'
  end
  
  it "should render the a list survey_invitations"
  it "should have a form that redirects to a survey"
  it "should have an accept button for each invitation"
  it "should have a decline button for each invitation"
  it "should have a button to create a new survey invitation"
  

end