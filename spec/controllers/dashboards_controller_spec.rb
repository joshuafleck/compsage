require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardsController do
  
  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
  end
  
end
