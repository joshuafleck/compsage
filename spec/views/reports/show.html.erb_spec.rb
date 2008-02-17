require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/1/reports/show" do
  before(:each) do
    render 'reports/show'
  end
  
  it "should show each question title"
  it "should show a flash graph for each question with options"
  it "should not show questions that are not numberable (like text instructions)"
end
