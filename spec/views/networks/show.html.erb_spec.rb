require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/show" do

  before(:each) do
    render 'networks/show'
  end
  
  it "should render the show form"
  it "should display the title"
  it "should display the description"
  it "should display the public/private status"
  it "should list the organizations belonging to the network with a link to each org page"
  it "should display the owner with a link to their org page"
  it "should have the ability to invite new members if the network is public, or the current org is the owner of the network"
	it "should have a link for editing/deleting the network if the org is the owner of the network"
	it "should have a link for leaving the network if the org is a member of the network"
	it "should have a link for joining the network if the org is not a member of the network"	

end
