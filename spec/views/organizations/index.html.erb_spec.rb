require File.dirname(__FILE__) + '/../../spec_helper'

describe "/organizations/index" do
  before(:each) do
    render 'organizations/index'
  end
  
  it "should show a search box"
end