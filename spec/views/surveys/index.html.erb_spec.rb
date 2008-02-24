require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/index" do

  before(:each) do
    render 'surveys/index'
  end
  
  it "should render the a list of surveys and their attributes"
  it "should have an edit button for each sponsored survey"
  it "should have a link to see the results of each complete survey"
  it "should have an accept or decline buton next to each pending survey"
  it "should have a link to the discussion for each survey"
  it "should have a link to invite users to the survey if the organization is the sponsor"
end