require File.dirname(__FILE__) + '/../spec_helper'
#These specs are from the vantage point of an invitee.
describe InvitationsController, "#route_for" do

  it "should map { :controller => 'invitations', :action => 'index' } to /invitations" do
    route_for(:controller => "invitations", :action => "index").should == "/invitations"
  end

  it "should map { :controller => 'invitations', :action => 'destroy', :id => 1} to /invitations/1" do
    route_for(:controller => "invitations", :action => "destroy", :id => 1).should == "/invitations/1"    
  end

end

describe InvitationsController, " handling GET /invitations" do

  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @survey_invitations = [mock_model(SurveyInvitation)]
    @network_invitations = [mock_model(NetworkInvitation)]
    
    @current_organization.stub!(:survey_invitations).and_return(@survey_invitations)
    @current_organization.stub!(:network_invitations).and_return(@network_invitations)
    
  end
  
  def do_get
    get :index
  end
    
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should require login" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should render index template" do
    do_get
    response.should render_template('index')
  end
  
  it "should find all non-accepted invitations" do
    @current_organization.should_receive(:survey_invitations).and_return(@survey_invitations)
    @current_organization.should_receive(:network_invitations).and_return(@network_invitations)
    do_get
  end
  
  it "should assign the found invitations to the view" do
    do_get
    assigns[:survey_invitations].should_not be_nil
    assigns[:network_invitations].should_not be_nil
  end
  
end

describe InvitationsController, " handling GET /invitations.xml" do
  
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @invitations = [mock_model(Invitation)]
    
    @current_organization.stub!(:invitations).and_return(@invitations)
    
    @invitations.stub!(:to_xml).and_return("XML")
    
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index
  end
    
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should require login" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should find all non-accepted invitations" do
    @current_organization.should_receive(:invitations).and_return(@invitations)
    do_get
  end
  
  it "should render the found invitations as XML" do
    @invitations.should_receive(:to_xml).and_return("XML")
    do_get
  end
  
end

describe InvitationsController, " handling DELETE /invitations/1" do  
  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    
    @invitation = mock_model(Invitation)
    @invitations = [@invitation]
    
    @current_organization.stub!(:invitations).and_return(@invitations)
    
    @invitations.stub!(:find).and_return(@invitation)    
    
    @invitation.stub!(:destroy).and_return(true)
    
    @params = {"id" => "1"}
    
  end
  
  def do_delete
    delete :destroy, @params
  end
  
  it "should require login" do
    controller.should_receive(:login_required)
    do_delete
  end
  
  it "should find the invitation" do
    @invitations.should_receive(:find).and_return(@invitation)
    do_delete
  end
  
  it "should destroy the invitation" do
    @invitation.should_receive(:destroy)
    do_delete
  end
  
  describe "when the request is HTML" do

    it "should redirect to the network index" do
      do_delete
      response.should redirect_to(invitations_path)    
    end
    
    it "should flash a message regarding the success of the action" do
      do_delete
      flash[:notice].should eql("The invitation was deleted successfully.")
    end
  
  end
  
end


