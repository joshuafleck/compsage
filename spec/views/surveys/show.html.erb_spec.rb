require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/show" do

  before(:each) do
    render 'surveys/show'
  end
  
  it "should render the survey attributes"
  it "should have an edit button for a sponsored survey"
  it "should have a link to see the results of a complete survey"
  it "should have a link to the discussion for the survey"
  it "should have the list of questions for the survey"
  it "should have the a link to edit each question if the user is the survey sponsor"

end