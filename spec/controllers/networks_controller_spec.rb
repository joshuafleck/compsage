require File.dirname(__FILE__) + '/../spec_helper'

describe NetworksController, "#route_for" do
  it "should map { :controller => 'networks', :action => 'index' } to /networks" do
    route_for(:controller => "networks", :action => "index").should == "/networks"
  end

  it "should map { :controller => 'networks', :action => 'new' } to /networks/new" do
    route_for(:controller => "networks", :action => "new").should == "/networks/new"
  end

  it "should map { :controller => 'networks', :action => 'show', :id => 1 } to /networks/1" do
    route_for(:controller => "networks", :action => "show", :id => 1).should == "/networks/1"
  end

  it "should map { :controller => 'networks', :action => 'edit', :id => 1 } to /networks/1/edit" do
    route_for(:controller => "networks", :action => "edit", :id => 1).should == "/networks/1/edit"
  end

  it "should map { :controller => 'networks', :action => 'update', :id => 1} to /networks/1" do
    route_for(:controller => "networks", :action => "update", :id => 1).should == "/networks/1"
  end

  it "should map { :controller => 'networks', :action => 'destroy', :id => 1} to /networks/1" do
    route_for(:controller => "networks", :action => "destroy", :id => 1).should == "/networks/1" 
  end
  
  it "should map { :controller => 'networks', :action => 'leave', :id => 1} to /networks/1/leave" do
    #route_for(:controller => "networks", :action => "leave", :id => 1).should == "/networks/1/leave"  
    pending
  end

  it "should map { :controller => 'networks', :action => 'join', :id => 1} to /networks/1/join" do
    #route_for(:controller => "networks", :action => "join", :id => 1).should == "/networks/1/join"
    pending
  end
end

describe NetworksController, " handling GET /networks" do

  it "should be successful" do
    pending    
  end
  
  it "should render index template" do
    pending    
  end
  
  it "should find all networks the organization belongs to" do
    pending    
  end
  
  it "should assign the found networks for the view" do
    pending    
  end
  
  it "should support sorting..." do
    pending
  end
    
  it "should support pagination..." do
    pending
  end
  
end

describe NetworksController, " handling GET /networks.xml" do

  it "should be successful" do
    pending    
  end
  
  it "should find all networks the organization belongs to" do
    pending    
  end
  
  it "should render the found networks as XML" do
    pending    
  end
  
end

describe NetworksController, " handling GET /networks/1" do

  it "should be successful" do
    pending    
  end

  it "should find the network requested" do
    pending    
  end  
  
  it "should set the 'joined' flag when the organization is a member of the network" do
    pending    
  end  

  it "should render the show template" do
    pending    
  end
  
  it "should assign the found network to the view" do
    pending    
  end
  
end

describe NetworksController, " handling GET /networks/1 when the current organization is not a member" do
  it "should not be successful" do
    
  end
end

describe NetworksController, " handling GET /networks/1.xml" do

  it "should be successful" do
    pending    
  end
   
  it "should find the network requested" do
    pending    
  end

  it "should find all members of the network" do
    pending    
  end
  
  it "should render the found network and network members as XML" do
    pending    
  end
  
end

describe NetworksController, " handling GET /networks/new" do

  it "should be successful" do
    pending    
  end

  it "should render new template" do
    pending    
  end
  
end

describe NetworksController, " handling GET /networks/1/edit" do

  it "should be successful" do
    pending    
  end
  
  it "should find the network requested" do
    pending    
  end
  
  it "should render the edit template" do
    pending    
  end
  
  it "should assign the found network to the view" do
    pending    
  end

end

describe NetworksController, " handling GET /networks/1/edit when the current organziation isn't the owner" do
  it "should not be successful"
end

describe NetworksController, " handling POST /networks" do

  it "should create a new network" do
    pending    
  end
  
  it "should make the owner a member of the network" do
    pending    
  end
  
  it "should return a response regarding the success of the action when the request is XML" do
    pending
  end
  
  it "should redirect to the show invitation view" do
    pending    
  end
    
  it "should flash a message regarding the success of the creation" do
    pending    
  end
  
end

describe NetworksController, " handling PUT /networks/1" do

  it "should find the network requested" do
    pending    
  end
  
  it "should update the selected network" do
    pending    
  end
 
  it "should return a response regarding the success of the action when the request is XML" do
    pending
  end
 
   
  it "should redirect to the network show page" do
    pending    
  end
  
  it "should flash a message regarding the success of the edit" do
    pending    
  end

end

describe NetworksController, " handling PUT /networks/1 when the current organization is not the owner" do
  it "should not be successful"
end

describe NetworksController, " handling PUT /networks/1/leave" do

  it "should find the network requested" do
    pending    
  end
  
  it "should allow the organization to leave the network" do
    pending    
  end

  it "should return a response regarding the success of the action when the request is XML" do
    pending
  end

  it "should redirect to the network index" do
    pending    
  end
  
  it "should flash a message regarding the success of the action" do
    pending    
  end

end

#We cannot allow the owner to leave the network without changing the owner
#If the owner leaves the network, the network will no longer show up in that owner's index page
describe NetworksController, "handling PUT /networks/1/leave when the organization is the owner of the network" do

  it "should return an error when the request is XML" do
    pending
  end

  it "should redirect to the network edit page" do
    pending
  end
  
  it "should flash a message instructing the organization to change the owner of the network" do
    pending
  end

end

describe NetworksController, " handling PUT /networks/1/join" do
  
  it "should require an invitation"
  
  it "should add the organization to the network" do
    pending
  end

  it "should destroy the invitation when an invitation exists" do
    pending
  end

  it "should return a response regarding the success of the action when the request is XML" do
    pending
  end
  
  it "should redirect to the network show page" do
    pending    
  end

  it "should flash a message regarding the success of the action" do
    pending    
  end  
end

describe NetworksController, " handling DELETE /networks/1" do

  it "should find the network requested" do
    pending    
  end
  
  it "should destroy the network" do
    pending    
  end
 
  it "should return a response regarding the success of the action when the request is XML" do
    pending
  end
   
  it "should redirect to the network index" do
    pending    
  end
  
  it "should flash a message regarding the success of the delete" do
    pending
  end

end

describe NetworksController, " handling Authentication" do
  include AuthenticationRequiredSpecHelper
  
  it "should require login for all actions" do
    controller_actions_should_fail_if_not_logged_in 'Networks'
  end
end

