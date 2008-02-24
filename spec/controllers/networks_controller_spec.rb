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
  
  it "should map { :controller => 'networks', :action => 'search' } to /networks/search" do
    #route_for(:controller => "networks", :action => "search").should == "/networks/search"
  end
  
end

describe NetworksController, " handling GET /networks" do
  it "should be successful"
  it "should render index template"
  it "should find all networks the org belongs to"
  it "should find all networks the org owns"
  it "should assign the found networks for the view"
end

describe NetworksController, " handling GET /networks.xml" do
  it "should be successful"
  it "should find all networks owned by the organization"
  it "should find all networks the org belongs to"
  it "should render the found networks as XML"
end

describe NetworksController, " handling GET /networks/1" do
  it "should be successful"
  it "should find the network requested if it is public"
  it "should find the network requested if it is private and the org is a member of the network"
  it "should find the network requested if it is private and the org is invited to the network"
  it "should find all members of the network"
  it "should flash an error and redirect to the network index if it is private and the org is not a member of the network"
  it "should render the show template"
  it "should assign the found network and network members to the view"
end

describe NetworksController, " handling GET /networks/1.xml" do
  it "should be successful"
  it "should find the network requested if it is public"
  it "should find the network requested if it is private and the org is a member of the network"
  it "should find the network requested if it is private and the org is invited to the network"
  it "should return an error if it is private and the org is not a member of the network"
  it "should find all members of the network"
  it "should render the found network and network members as XML"
end

describe NetworksController, " handling GET /networks/new" do
  it "should be successful"
  it "should fail, redirect to the network index, and flash a message if the organization is in private mode"
  it "should render new template"
  it "should redirect to the network_invitations new view"
end

describe NetworksController, " handling GET /networks/1/edit" do
  it "should be successful"
  it "should find the network requested"
  it "should render the edit template if the org is the owner of the network"
  it "should assign the found network to the view if the org is the owner of the network"
  it "should redirect to the show network page and flash a message if the org is not the owner of the network"
end

describe NetworksController, " handling POST /networks" do
  it "should create a new network by owner"
  it "should make the owner a member of the network"
  it "should fail, redirect to the network index, and flash a message if the organization is in private mode"
  it "should redirect to the new network"
  it "should flash a message regarding the success of the creation"
end

describe NetworksController, " handling PUT /networks/1" do
  it "should find the network requested"
  it "should update the selected network if the org is the owner of the network"
  it "should return an error if the org is not the owner of the network"
  it "should redirect to the updated network show page"
  it "should flash a message regarding the success of the edit"
end

describe NetworksController, " handling PUT /networks/1/leave" do
  it "should find the network requested"
  it "should allow the org to leave the network if it is a member of the network"
  it "should return an error if the org is not member of the network"
  it "should redirect to the network index"
  it "should flash a message regarding the success of the action"
end

describe NetworksController, " handling PUT /networks/1/join" do
  it "should find the network requested"
  it "should allow the org to join the network if it is not a member of the network and the network is public"
  it "should not allow the organization to join the network if it is in private mode"
  it "should allow the org to join the network if it is invited to the network"
  it "should destroy the network invitation when an invited org joins the network if an ivitation exists"
  it "should assign the found network to the view"
  it "should return an error if the network is private and the org is not invited to the network"
  it "should return an error if the network is public and the org is already a member"
  it "should return an error if the organization is in private mode"
  it "should redirect to the target network on success or failure"
  it "should flash a message regarding the success of the action"
end

describe NetworksController, " handling DELETE /networks/1" do
  it "should find the network requested"
  it "should destroy the network requested if the org is the owner of the network"
  it "should return an error if the org does not own the network"
  it "should redirect to the network index"
end

describe NetworksController, "handling GET /networks/search" do
	it "should find public networks of which the organization is not a member by the input text"
	it "should search by title and/or description depending on the arguments provided"
	it "should assign the found networks to the view"
	it "should assign the search terms to the view"
	it "should render the search page"
  it "should flash a message if no networks were found after a search was performed"
end

describe NetworksController, "handling GET /networks/search.xml" do
	it "should find public networks of which the organization is not a member by the input text"
	it "should search by title and/or description depending on the arguments provided"
	it "should list the found networks in the XML"
	it "should list the search text in the XML"
	it "should list the search terms (title and/or description) in the XML"
end

