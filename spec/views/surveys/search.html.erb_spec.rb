require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/search" do

  before(:each) do
    render 'surveys/search'
  end
  it "should have search controls populated with search terms"
  it "should have a 'Search Again' button"
  it "should have a link to more search options"
  it "should show a list of surveys"
  it "should have have controls for sorting surveys"
  it "should render the a list of surveys and their attributes"
  it "should have an edit button for each sponsored survey"
  it "should have a link to see the results of each complete survey"
  it "should have an 'Take Now' or 'Decline' buton next to each active survey"
  it "should have a link to the discussion for each survey"
  it "should have a link to invite users to the survey if the organization is the sponsor"
  it "should be paged if the user has more then X surveys"
  it "should allow the user to select the X number of surveys to show per page"
  

end