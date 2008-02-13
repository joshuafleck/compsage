require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardsController, "#route_for" do

  it "should map { :controller => 'dashboards', :action => 'index' } to /dashboards" do
    #route_for(:controller => "dashboards", :action => "index").should == "/dashboards"
  end

end
 
describe DashboardsController, " handling GET /dashboards" do

  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
  end
  
  it "should render index template"
  it "should find all received messages since last login"
  it "should find all survey invitations received since last login"
  it "should find all network invitations received since last login"
  it "should find all completed surveys for your org since last login"
  it "should assign the found information for the view"
end

  

  