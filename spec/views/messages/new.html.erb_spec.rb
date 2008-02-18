require File.dirname(__FILE__) + '/../../spec_helper'

describe "/messages/new" do

  before(:each) do
    render 'messages/new'
  end
  
  it "should render the new message form"
  it "should have a means for selecting the recipient"
  it "should have a means for inserting a subject"
  it "should have a means for inserting the body"
  it "should have a cancel button that links back to the index page"
  it "should have a submit"

end
