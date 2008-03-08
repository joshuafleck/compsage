require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardsController, "#route_for" do

  it "should map { :controller => 'dashboards', :action => 'show' } to /dashboard" do
    #route_for(:controller => "dashboards", :action => "show").should == "/dashboard"
    pending
  end

end
 
describe DashboardsController, " handling GET /dashboard" do

  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
  end
  
  it "should render the show template" do
  	pending
  end

  it "should find X most recent survey invitations received" do
  	pending
  end
  
  it "should find X most recent network invitations received" do
  	pending
  end
  
  it "should find X most recent running surveys the organization sponsored or participated in" do
  	pending
  end
  
  it "should find X most recent completed surveys the organization sponsored or participated in" do
  	pending
  end
  
  it "should assign the found information for the view" do
  	pending
  end
  
end

  

  
