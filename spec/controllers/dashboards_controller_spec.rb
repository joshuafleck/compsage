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
  it "should find all received messages since last login"
  it "should find all survey invitations received since last login"
  it "should find all network invitations received since last login"
  it "should find all running surveys with activity since the users last login. Activity includes: new discussion posts..."
  it "should find all completed surveys the organization sponsored or participated in since last login"
  it "should assign the found information for the view"
end

  

  
