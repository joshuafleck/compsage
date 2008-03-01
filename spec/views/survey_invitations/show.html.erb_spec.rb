require File.dirname(__FILE__) + '/../../spec_helper'

describe "/survey_invitations/show" do

  before(:each) do
    render 'survey_invitations/show'
  end
  
  it "should render the survey invitation attributes"
  it "should have a form that redirects to a survey"
  it "should have an delete button for each invitation"

end