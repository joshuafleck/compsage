require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardsController, "#route_for" do

  it "should map { :controller => 'dashboards', :action => 'show' } to /dashboard" do
    route_for(:controller => "dashboards", :action => "show").should == "/dashboard"
  end

end
 
describe DashboardsController, " handling GET /dashboard" do

  before do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @survey_invitations_proxy = mock('survey invitations proxy')
    @survey_invitations_proxy.stub!(:recent).and_return([])
    @current_organization.stub!(:survey_invitations).and_return(@survey_invitations_proxy)
    
    @network_invitations_proxy = mock('network invitations proxy')
    @network_invitations_proxy.stub!(:recent).and_return([])
    @current_organization.stub!(:network_invitations).and_return(@network_invitations_proxy)
    
    @current_organization.stub!(:recent_running_surveys).and_return([])
    @current_organization.stub!(:recent_completed_surveys).and_return([])
  end
  
  it "should be successful" do
    get :show
    response.should be_success
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    get :show
  end
  
  it "should render the show template" do
  	get :show
  	response.should render_template('show')
  end

  it "should find 10 most recent survey invitations received" do
    @survey_invitations_proxy.should_receive(:recent)
  	get :show
  end
  
  it "should find 10 most recent network invitations received" do
    @network_invitations_proxy.should_receive(:recent)
  	get :show
  end
  
  it "should find 10 most recent running surveys the organization sponsored or participated in" do
    @current_organization.should_receive(:recent_running_surveys)
    get :show
  end
  
  it "should find 10 most recent completed surveys the organization sponsored or participated in" do
    @current_organization.should_receive(:recent_completed_surveys)
  	get :show
  end
  
  it "should assign the found information for the view" do
  	get :show
  	assigns[:recent_survey_invitations].should_not be_nil
  	assigns[:recent_network_invitations].should_not be_nil
  	assigns[:recent_running_surveys].should_not be_nil
  	assigns[:recent_completed_surveys].should_not be_nil
  end
  
end

  

  
