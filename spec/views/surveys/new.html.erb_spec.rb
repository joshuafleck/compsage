require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/new" do

  before(:each) do
    render 'surveys/new'
  end
  
  it "should render the new surveys form"
  it "should render the survey questions form"
  it "should have a submit button"
  it "should have a cancel link"

end