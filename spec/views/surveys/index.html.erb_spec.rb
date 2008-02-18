require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/index" do

  before(:each) do
    render 'surveys/index'
  end
  
  it "should render the a list of surveys and their attributes"

end