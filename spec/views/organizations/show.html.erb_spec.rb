require File.dirname(__FILE__) + '/../../spec_helper'

describe "/organizations/show" do
  before(:each) do
    render 'organizations/show'
  end
  
  it "should show the organization attributes in some way"
end
