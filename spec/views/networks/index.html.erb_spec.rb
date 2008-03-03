require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/index" do

  before(:each) do
    render 'networks/index'
  end
  
  it "should show the list of networks" do
  	pending
  end
  
  it "should display the title of each network" do
  	pending
  end
  
  it "should display the number of members for each network" do
  	pending
  end
  
  it "should have a link to show each network" do
  	pending
  end
  
  describe "when a network is owned by the organization" do
  
  	it "should have a link to edit the network" do
  		pending
  	end
  	
  	it "should have a link to delete the network" do 
  		pending
  	end
  
  end

	it "should have a link for inviting organizations when displaying a public network" do
  	pending
	end
	
  it "should have a link for creating a new network" do
  	pending
  end
  
 	it "should have a link for leaving each network" do
  	pending
  end
  
  it "should show a search form" do
  	pending
  end
  
  it "should have a means for submitting search text" do
  	pending
  end
  
  it "should have a checkbox for allowing the organization to search by title" do
  	pending
  end
  
  it "should have a checkbox for allowing the organization to search by description" do
  	pending
  end
  
  it "should have a checkbox for excluding networks the organization is already a member of" do
  	pending
  end
  
  it "should have a submit button" do
  	pending
  end
     
end
