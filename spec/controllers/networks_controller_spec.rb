require File.dirname(__FILE__) + '/../spec_helper'

describe NetworksController, "when an illegal action has been attempted", :shared => true do

	describe "when the request is XML" do
	 	
	 		it "should return an error" do
	 			pending	 		
	 		end
	 	
	 	end
	 	
	 	describe "when the request is HTML" do
	 	
		 	it "should redirect to the network index page" do
		 		pending
		 	end
		 	
		 	it "should flash an error message" do
		 		pending
		 	end
	 	
	 	end

end

describe NetworksController, "#route_for" do

  it "should map { :controller => 'networks', :action => 'index' } to /networks" do
    #route_for(:controller => "networks", :action => "index").should == "/networks"
    pending
  end

  it "should map { :controller => 'networks', :action => 'new' } to /networks/new" do
    #route_for(:controller => "networks", :action => "new").should == "/networks/new"
    pending    
  end

  it "should map { :controller => 'networks', :action => 'show', :id => 1 } to /networks/1" do
    #route_for(:controller => "networks", :action => "show", :id => 1).should == "/networks/1"
    pending    
  end

  it "should map { :controller => 'networks', :action => 'edit', :id => 1 } to /networks/1/edit" do
    #route_for(:controller => "networks", :action => "edit", :id => 1).should == "/networks/1/edit"
    pending    
  end

  it "should map { :controller => 'networks', :action => 'update', :id => 1} to /networks/1" do
    #route_for(:controller => "networks", :action => "update", :id => 1).should == "/networks/1"
    pending    
  end

  it "should map { :controller => 'networks', :action => 'destroy', :id => 1} to /networks/1" do
    #route_for(:controller => "networks", :action => "destroy", :id => 1).should == "/networks/1"
    pending    
  end
  
  it "should map { :controller => 'networks', :action => 'leave', :id => 1} to /networks/1/leave" do
    #route_for(:controller => "networks", :action => "leave", :id => 1).should == "/networks/1/leave"
    pending    
  end

  it "should map { :controller => 'networks', :action => 'join', :id => 1} to /networks/1/join" do
    #route_for(:controller => "networks", :action => "join", :id => 1).should == "/networks/1/join"
    pending    
  end
  
  it "should map { :controller => 'networks', :action => 'search' } to /networks/search" do
    #route_for(:controller => "networks", :action => "search").should == "/networks/search"
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
 
  describe " for a private network" do
    	
    describe "where the organization is not a member of the network" do
    
			it_should_behave_like "NetworksController when an illegal action has been attempted"
		
    end

	end

  it "should find the network requested" do
	  pending    
  end  
  
  it "should render the show template" do
    pending    
  end
  
  it "should assign the found network to the view" do
    pending    
  end
  
end

describe NetworksController, " handling GET /networks/1.xml" do

  it "should be successful" do
    pending    
  end

  describe " for a private network" do
  
  	describe "when the organization is not a member of the network" do
    
			it_should_behave_like "NetworksController when an illegal action has been attempted"
		
  	end
  	
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
  
  describe " when the organization is in private mode" do
    
			it_should_behave_like "NetworksController when an illegal action has been attempted"
		
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
  
  describe "when the organization is not the owner of the network" do
    
			it_should_behave_like "NetworksController when an illegal action has been attempted"
		
  end
  
  it "should render the edit template" do
    pending    
  end
  
  it "should assign the found network to the view" do
    pending    
  end

end

describe NetworksController, " handling POST /networks" do

 	describe "when the organization is in private mode" do

		it_should_behave_like "NetworksController when an illegal action has been attempted"
		 		
 	end

  it "should create a new network by owner" do
    pending    
  end
  
  it "should make the owner a member of the network" do
    pending    
  end
  
  it "should redirect to the new invitation view" do
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
  
  describe "when the organization is not the owner of the network" do
    
		it_should_behave_like "NetworksController when an illegal action has been attempted"
		
  end
  
  it "should update the selected network" do
    pending    
  end
 
  it "should redirect to the network show page" do
    pending    
  end
  
  it "should flash a message regarding the success of the edit" do
    pending    
  end
  
end

describe NetworksController, " handling PUT /networks/1/leave" do

	describe "when the organization is not a member of the network" do
    
		it_should_behave_like "NetworksController when an illegal action has been attempted"
		
	end

  it "should find the network requested" do
    pending    
  end
  
  #We cannot allow the owner to leave the network without changing the owner
  #If the owner leaves the network, the network will no longer show up in that owner's index page
  describe "when the organization is the owner of the network" do
  
  	describe "when the request is XML" do
  	
  		it "should return an error" do
  			pending
  		end
  	
  	end
  	
  	it "should redirect to the network edit page" do
  		pending
  	end
  	
  	it "should flash a message instructing the organization to change the owner of the network" do
  		pending
  	end
  
  end
  
  it "should allow the organization to leave the network" do
    pending    
  end

  it "should redirect to the network index" do
    pending    
  end
  
  it "should flash a message regarding the success of the action" do
    pending    
  end
  
end

describe NetworksController, " handling PUT /networks/1/join" do

	describe "when the organization is in private mode" do
    
		it_should_behave_like "NetworksController when an illegal action has been attempted"
		
	end

	describe "when the organization is already a member of the network" do
    
		it_should_behave_like "NetworksController when an illegal action has been attempted"
		
	end
	
	describe "when the network is private" do
	
		describe "when the organization is not invited to the network" do
    
			it_should_behave_like "NetworksController when an illegal action has been attempted"
		
		end
	
	end

	it "should add the organization to the network"	do
		pending
	end
	 
	describe "when an invitation exists" do
	
		it "should update the status of the invitation to accepted" do
			pending
		end
	
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
  
  describe "when the organization is not the owner of the network" do
    
		it_should_behave_like "NetworksController when an illegal action has been attempted"
		
  end
  
  it "should destroy the network requested" do
    pending    
  end
 
  it "should redirect to the network index" do
    pending    
  end
  
  it "should flash a message regarding the success of the delete" do
  	pending
  end
  
end

describe NetworksController, "handling GET /networks/search" do

	it "should search for public networks" do
		pending
	end
	
	describe "when the search excludes joined networks"do
	
		it "should search unjoined networks" do
			pending
		end
	
	end

	describe "when the search is by title" do
	
		it "should search for networks with titles containing the search text" do
			pending
		end
	
	end
	
	describe "when the search is by description"do
	
		it "should search for networks with descriptions containing the search text" do
			pending
		end
	
	end
	
	describe "when the search is by description and title"do
	
		it "should search for networks with descriptions or titles containing the search text" do
			pending
		end
	
	end	

	it "should assign the found networks to the view" do
    pending    
  end
  
	it "should assign the search terms to the view" do
    pending    
  end

end

describe NetworksController, "handling GET /networks/search.xml" do

	it "should search for public networks" do
		pending
	end
	
	describe "when the search excludes joined networks"do
	
		it "should search unjoined networks" do
			pending
		end
	
	end

	describe "when the search is by title" do
	
		it "should search for networks with titles containing the search text" do
			pending
		end
	
	end
	
	describe "when the search is by description"do
	
		it "should search for networks with descriptions containing the search text" do
			pending
		end
	
	end
	
	describe "when the search is by description and title" do
	
		it "should search for networks with descriptions or titles containing the search text" do
			pending
		end
	
	end	

	it "should render the found networks as XML" do
    pending    
  end
   
end

