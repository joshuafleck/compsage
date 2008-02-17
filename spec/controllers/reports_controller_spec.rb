require File.dirname(__FILE__) + '/../spec_helper'

describe ReportsController, "#route_for" do  
  it "should map { :controller => 'reports', :action => 'show', :survey_id => 1 } to /surveys/1/report" do
    route_for(:controller => "reports", :action => "show", :survey_id => 1 ).should == "/surveys/1/report"
  end
end

describe ReportsController, "with access limits", :shared => true do
  it "should return an error if the organization has not responded to the survey or isn't the sponsor"
  it "should return an error if the survey participation window is not finished"
end

describe ReportsController, "handling GET /survey/1/report" do
  it_should_behave_like "ReportsController with access limits"
  
  it "should be successful"
end

describe ReportsController, "handling GET /responses/1.xml" do
  it_should_behave_like "ReportsController with access limits"
  
  it "should be successful"
  it "should render the aggregate report as xml"
end