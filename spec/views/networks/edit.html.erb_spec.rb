require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/edit" do

  before(:each) do
    render 'networks/edit'
  end
  
  it "should render the edit form"
  it "should have a means for editing the title"
  it "should have a means for editing the description"
  it "should have a means for editing the public/private status"
  it "should have a means for changing the owner"
  it "should prepopulate the editable fields with their current values"
  it "should have a submit button"
  it "should have a cancel button"

end
