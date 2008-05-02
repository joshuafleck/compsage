require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/show" do

  before(:each) do
    render 'networks/show'
  end
  
  it "should display the title" do
    pending
  end
  
  it "should display the description" do
    pending
  end
  
  it "should list the members of the network" do
    pending
  end
  
  it "should display the owner with a link to their organization's page" do
    pending
  end
  
  describe "when the organization is the owner of the network" do
  
    it "should have a link for inviting organizations" do
      pending
    end
    
    it "should have a button for deleting the network" do
      pending
    end
    
    it "should have a link for editing the network" do
      pending
    end
  
  end

  it "should have a button for leaving the network when the organization is a member of the network" do
    pending
  end

end
