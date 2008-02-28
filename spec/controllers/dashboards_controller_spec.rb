require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardsController, "#route_for" do

  it "should map { :controller => 'dashboards', :action => 'show' } to /dashboards" do
    #route_for(:controller => "dashboards", :action => "show").should == "/dashboards"
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
  it "should find X most recent received messages"
  it "should find X most recent survey invitations received"
  it "should find X most recent network invitations received"
  it "should find X most recent running surveys the organization sponsored or participated in"
  it "should find X most recent completed surveys the organization sponsored or participated in"
  it "should assign the found information for the view"
end

describe DashboardsController, " handling GET /dashboards.xml" do

  it "should find X most recent received messages"
  it "should find X most recent survey invitations received"
  it "should find X most recent network invitations received"
  it "should find X most recent running survey the organization sponsored or participated ins"
  it "should find X most recent completed surveys the organization sponsored or participated in"
  it "should list all found objects in the XML"
  
end

  

  
