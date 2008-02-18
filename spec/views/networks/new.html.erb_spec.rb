require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/new" do

  before(:each) do
    render 'networks/new'
  end
  
  it "should render the new form"
  it "should have a means for editing the title"
  it "should have a means for editing the description"
  it "should have a means for editing the public/private status"
  it "should have a submit button"
  it "should have a cancel button that links back to the index page"

end
