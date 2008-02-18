require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/show with xml" do

  before(:each) do
    render 'networks/show.xml.builder'
  end
  
  it "should contain the title"
  it "should contain the description"
  it "should contain the public/private status"
  it "should contain a list of the organization ids of the members"
  it "should contain the id of the owner"

end
