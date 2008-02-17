require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/1/reports/show with xml" do
  before(:each) do
    render 'reports/show.xml.builder'
  end
  
  it "should have results for each question"
  it "should indicate the survey"
  it "should have the question text for each question"
  it "should have the type of response expected for each question"
  it "should have a list of responses for text-response questions"
  it "should have an average for numerical-response questions"
  it "should have an option breakdown for each question with options"
  it "should not have questions that aren't numberable like instructions"
end
