require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/show" do

  before(:each) do
    render 'surveys/show'
  end
  
  it "should render the survey attributes"
  it "should have an edit button for each sponsored survey"
  it "should have a link to see the results of each complete survey"
  it "should have an accept or decline buton next to each pending survey"
  it "should have a link to the discussion for each survey"

end