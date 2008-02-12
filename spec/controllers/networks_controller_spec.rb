require File.dirname(__FILE__) + '/../spec_helper'

describe NetworksController, "#route_for" do

  it "should map { :controller => 'networks', :action => 'index' } to /networks" do
    #route_for(:controller => "networks", :action => "index").should == "/networks"
  end

  it "should map { :controller => 'networks', :action => 'new' } to /networks/new" do
    #route_for(:controller => "networks", :action => "new").should == "/networks/new"
  end

  it "should map { :controller => 'networks', :action => 'show', :id => 1 } to /networks/1" do
    #route_for(:controller => "networks", :action => "show", :id => 1).should == "/networks/1"
  end

  it "should map { :controller => 'networks', :action => 'edit', :id => 1 } to /networks/1;edit" do
    #route_for(:controller => "networks", :action => "edit", :id => 1).should == "/networks/1;edit"
  end

  it "should map { :controller => 'networks', :action => 'update', :id => 1} to /networks/1" do
    #route_for(:controller => "networks", :action => "update", :id => 1).should == "/networks/1"
  end

  it "should map { :controller => 'networks', :action => 'destroy', :id => 1} to /networks/1" do
    #route_for(:controller => "networks", :action => "destroy", :id => 1).should == "/networks/1"
  end
  
  it "should map { :controller => 'networks', :action => 'leave', :id => 1} to /networks/1/leave" do
    #route_for(:controller => "networks", :action => "leave", :id => 1).should == "/networks/1/leave"
  end

  it "should map { :controller => 'networks', :action => 'join', :id => 1} to /networks/1/join" do
    #route_for(:controller => "networks", :action => "join", :id => 1).should == "/networks/1/join"
  end
  
end

describe NetworksController, " handling GET /networks" do
  it "should be successful"
  it "should render index template"
  it "should find all public networks"
  it "should find all private networks the org belongs to"
  it "should assign the found networks for the view"
end

describe NetworksController, " handling GET /networks.xml" do
  it "should be successful"
  it "should find all public networks"
  it "should find all private networks the org belongs to"
  it "should render the found networks as XML"
end

describe NetworksController, " handling GET /networks/1" do
  it "should be successful"
  it "should find the network requested if it is public"
  it "should find the network requested if it is private and the org is a member of the network"
  it "should find the network requested if it is private and the org is invited to the network"
  it "should flash an error and redirect to the network index if it is private and the org is not a member of the network"
  it "should render the show template"
  it "should assign the found network to the view"
end

describe NetworksController, " handling GET /networks/1.xml" do
  it "should be successful"
  it "should find the network requested if it is public"
  it "should find the network requested if it is private and the org is a member of the network"
  it "should find the network requested if it is private and the org is invited to the network"
  it "should return an error if it is private and the org is not a member of the network"
  it "should render the found network as XML"
end

describe NetworksController, " handling GET /networks/new" do
  it "should be successful"
  it "should render new template"
end

describe NetworksController, " handling GET /networks/1/edit" do
  it "should be successful"
  it "should render the edit template if the org is the owner of the network"
  it "should find the network requested"
  it "should assign the found network to the view if the org is the owner of the network"
  it "should redirect to the show network and flash a message if the org is not the owner of the network"
end

describe NetworksController, " handling POST /networks" do
  it "should create a new network by owner"
  it "should redirect to the new network"
end

describe NetworksController, " handling PUT /networks/1" do
  it "should find the network requested"
  it "should update the selected network if the org is the owner of the network"
  it "should return an error if the org is not the owner of the network"
  it "should redirect to the updated network"
end

describe NetworksController, " handling PUT /networks/1/leave" do
  it "should find the network requested"
  it "should allow the org to leave the network if it is a member of the network"
  it "should redirect to the network index"
end

describe NetworksController, " handling PUT /networks/1/join" do
  it "should find the network requested"
  it "should allow the org to join the network if it is not a member of the network and the network is public"
  it "should destroy the network invitation when an invited org joins the network"
  it "should assign the found network to the view"
  it "should return an error if the network is private and the org is not invited to the network"
  it "should redirect to the joined network"
end

describe NetworksController, " handling DELETE /networks/1" do
  it "should find the network requested"
  it "should destroy the network requested if the org is the owner of the network"
  it "should return an error if the org does not own the network"
  it "should redirect to the network index"
end
