require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/index with xml" do
  before(:each) do
    render 'networks/index.xml.builder'
  end
  
  it "should render the list of networks and their attributes"
  
end
