require File.dirname(__FILE__) + '/../spec_helper'

describe NaicsClassificationsController, "#route_for" do
  it "should map { :controller => 'naics_classifications', :action => 'children_and_ancestors' } to /naics_classifications/children_and_ancestors" do
    route_for(:controller => "naics_classifications", :action => "children_and_ancestors") .should == "/naics_classifications/children_and_ancestors"
  end
end

describe NaicsClassificationsController, " handling GET /children_and_ancestors" do

  before(:each) do
    @naics = Factory.create(:naics_classification)
    @params = {:format => 'json'}
  end
  
  after(:each) do
    @naics.destroy
  end  
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/json"
    get :children_and_ancestors, @params
  end

  describe "when the current node has one child" do
  
    before(:each) do
      @naics1 = Factory.create(:naics_classification)
      @naics2 = Factory.create(:naics_classification)
      
      @naics1.move_to_child_of @naics
      @naics2.move_to_child_of @naics1      
      @params[:id] = @naics.code
      
    end  
    
    after(:each) do
      @naics2.destroy
      @naics1.destroy
    end      
    
    it "should drill down until the current node does not have 1 child and should find the ancestors of the drill down node" do
      do_get
      response.body.should == { 
          :children => [].to_json(
            :only => [:code, :description], 
            :methods => [:children_count, :display_code]), 
          :ancestors => @naics2.self_and_ancestors.to_json(
            :only => [:code, :description], 
            :methods => [:children_count, :display_code]) 
          }.to_json
    end
  
  end
  
  it "should return the root nodes as children and should not return any ancestors" do
    do_get
    response.body.should == { 
          :children => NaicsClassification.roots.to_json(
            :only => [:code, :description], 
            :methods => [:children_count, :display_code]), 
          :ancestors => [].to_json(
            :only => [:code, :description], 
            :methods => [:children_count, :display_code]) 
          }.to_json
  end
    
  it "should be successful" do
    do_get
    response.should be_success
  end
  
end
