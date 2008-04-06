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
    @survey_invitations_proxy.stub!(:find).and_return([])
    @current_organization.stub!(:survey_invitations).and_return(@survey_invitations_proxy)
    
    @network_invitations_proxy = mock('network invitations proxy')
    @network_invitations_proxy.stub!(:find).and_return([])
    @current_organization.stub!(:network_invitations).and_return(@network_invitations_proxy)
    
    @surveys_proxy = mock('surveys proxy')
    @surveys_proxy.stub!(:find).and_return([])
    @current_organization.stub!(:surveys).and_return(@surveys_proxy)
    
    Survey.stub!(:find).and_return([])
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
    @current_organization.should_receive(:survey_invitations).and_return(@survey_invitations_proxy)
    @survey_invitations_proxy.should_receive(:find).with(:all, :order => 'created_at DESC', :limit => 10).and_return([])
  	get :show
  end
  
  it "should find 10 most recent network invitations received" do
    @current_organization.should_receive(:network_invitations).and_return(@network_invitations_proxy)
    @network_invitations_proxy.should_receive(:find).with(:all, :order => 'created_at DESC', :limit => 10).and_return([])
  	get :show
  end
  
  it "should find 10 most recent running surveys the organization sponsored or participated in" do
    Survey.should_receive(:find).at_least(:once)
    get :show
  end
  
  it "should find 10 most recent completed surveys the organization sponsored or participated in" do
    Survey.should_receive(:find).at_least(:once)
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

  

  
