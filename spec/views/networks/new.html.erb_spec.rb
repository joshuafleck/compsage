require File.dirname(__FILE__) + '/../../spec_helper'

describe "/networks/new" do

  before(:each) do
    assigns[:network] = mock_model(Network, :name => "Network 1", :description => "Test Description")
    render 'networks/new'
  end
  
  it "should show the new form" do
    response.should have_tag("form")
  end
  
  it "should have a means for setting a name" do
    response.should have_tag("input[id=network_name]")
  end
  
  it "should have a means for setting a description" do
    response.should have_tag("textarea[id=network_description]")
  end
  
  it "should have a submit button" do
    response.should have_tag("input[type=submit]")
  end
  
  it "should have a cancel link that links back to the index page" do
    response.should have_tag("a[href=#{networks_path}]", "Cancel")
  end
end
