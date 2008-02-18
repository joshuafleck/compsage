require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/search with xml" do
  before(:each) do
    render 'networks/search.xml.builder'
  end
  
  it "should contain the search text"
  it "should contain a list of fields searched e.g. title and/or description"  
  it "should render the list of networks with their attributes"

end
