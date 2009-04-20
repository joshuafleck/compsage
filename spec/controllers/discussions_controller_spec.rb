require File.dirname(__FILE__) + '/../spec_helper'

describe DiscussionsController, "#route_for" do

  it "should map { :controller => 'discussions', :action => 'index' } to surveys/1/discussions" do
    route_for(:controller => "discussions", :action => "index", :survey_id => '1') .should == "/surveys/1/discussions"
  end

  it "should map { :controller => 'discussions', :action => 'update', :id => '1'} to surveys/1/discussions/1" do
    route_for(:controller => "discussions", :action => "update", :id => '1', :survey_id => '1').should == {:path => "/surveys/1/discussions/1", :method => :put}
  end

  it "should map { :controller => 'discussions', :action => 'destroy', :id => '1'} to surveys/1/discussions/1" do
    route_for(:controller => "discussions", :action => "destroy", :id => '1', :survey_id => '1').should == {:path => "/surveys/1/discussions/1", :method => :delete}
  end

  it "should map { :controller => 'discussions', :action => 'report', :id => '1'} to surveys/1/discussions/1/report" do
    route_for(:controller => "discussions", :action => "report", :id => '1', :survey_id => '1').should == "/surveys/1/discussions/1/report"
  end

end

describe DiscussionsController, " handling GET /discussions.xml" do
  
  before do
    @current_organization_or_survey_invitation = mock_model(Organization)
    login_as(@current_organization_or_survey_invitation)
    
    @discussion = mock_model(Discussion)
    
    @discussions = [@discussion]
    @discussions.stub!(:to_xml).and_return("XML")
    @discussions.stub!(:all).and_return(@discussions)
    
    @survey = mock_model(Survey, :id => 1, :job_title => 'Software Engineer')
    @survey.stub!(:discussions).and_return(@discussions)
    
    Survey.stub!(:find).and_return(@survey)
    
    @params = {:survey_id => @survey.id}
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_or_survey_invitation_required)
    do_get
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find all discussions" do
    @survey.should_receive(:discussions).and_return(@discussions)
    @discussions.should_receive(:all).and_return(@discussions)
    do_get
  end
  
  it "should render the found discussions as XML" do
    @discussions.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
    
end

describe DiscussionsController, " handling POST /discussions" do

  before(:each) do
    @current_organization_or_survey_invitation = mock_model(Organization)
    login_as(@current_organization_or_survey_invitation)
    
    @survey = mock_model(Survey, :id => 1)
    @discussion = mock_model(Discussion, :id => 1, :save => true, :survey= => @survey)  
    @discussions = [@discussion] 
    
    @survey_discussions_proxy = mock('survey discussions proxy', :discussions => @discussions)
    
    @organization_discussions_proxy = mock('organization discussions proxy')
    @organization_discussions_proxy.stub!(:new).and_return(@discussion)
    @current_organization_or_survey_invitation.stub!(:discussions).and_return(@organization_discussions_proxy)
    @survey.stub!(:discussions).and_return(@survey_discussions_proxy)
    
    Survey.stub!(:find).and_return(@survey)
    
    @params = {:survey_id => @survey.id}
  end
  
  def do_post
    post :create, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_or_survey_invitation_required)
    do_post
  end
  
  it "should create a new discussion" do
    @organization_discussions_proxy.should_receive(:new).and_return(@discussion)
    @discussion.should_receive(:save).and_return(true)
    do_post
  end
  
  it "should redirect to the discussion index page upon success" do
    do_post
    response.should redirect_to(survey_path(@survey))
  end
  
end

describe DiscussionsController, " handling POST /discussions with validation error" do

  before(:each) do
    @current_organization_or_survey_invitation = mock_model(Organization)
    login_as(@current_organization_or_survey_invitation)
    
    @survey = mock_model(Survey, :id => 1, :all_invitations => [])
    @discussion = mock_model(Discussion, :id => 1, :save => false, :survey= => @survey)  
    @discussions = [@discussion] 
    
    @participations_proxy = mock('participations proxy',:find_by_survey_id => [])
    @current_organization_or_survey_invitation.stub!(:participations).and_return(@participations_proxy)
    
    @survey_discussions_proxy = mock('survey discussions proxy', :discussions => @discussions)
    @survey_discussions_proxy.stub!(:within_abuse_threshold).and_return(@survey_discussions_proxy)
    @survey_discussions_proxy.stub!(:roots).and_return(@discussions)
    
    @organization_discussions_proxy = mock('organization discussions proxy')
    @organization_discussions_proxy.stub!(:new).and_return(@discussion)
    @current_organization_or_survey_invitation.stub!(:discussions).and_return(@organization_discussions_proxy)
    @survey.stub!(:discussions).and_return(@survey_discussions_proxy)
    
    Survey.stub!(:find).and_return(@survey)
    
    @params = {:survey_id => @survey.id}
  end
  
  def do_post
    post :create, @params
  end
  
  it "should render the survey show template" do
    do_post
    response.should render_template('surveys/show')
  end
  
end

describe DiscussionsController, " handling PUT /discussions/1" do

  before do
    @current_organization_or_survey_invitation = mock_model(Organization, :id => 1)
    login_as(@current_organization_or_survey_invitation)
    
    @discussion = mock_model(Discussion, :id => 1, :update_attributes => true, :body => "body")
    @survey = mock_model(Survey, :id => 1)
    
    @organization_discussions_proxy = mock('organization discussions proxy', :find => @discussion)
    @current_organization_or_survey_invitation.stub!(:discussions).and_return(@organization_discussions_proxy)
    
    Survey.stub!(:find).and_return(@survey)
    
    @params = {:survey_id => @survey.id, :id => @discussion.id, :discussion => {:subject => 'subject', :body => 'body'}}
  end
  
  def do_put
    @request.env["HTTP_ACCEPT"] = "text/javascript"
    put :update, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_or_survey_invitation_required)
    do_put
  end
  
  it "should find the discussion requested" do
    @organization_discussions_proxy.should_receive(:find).and_return(@discussion)
    do_put    
  end
  
  it "should update the selected discussion" do
    @discussion.should_receive(:update_attributes).and_return(true)
    do_put
  end
     
  it "should return the updated text" do
    do_put
    response.body.should eql('body')
  end
  
end

describe DiscussionsController, " handling PUT /discussions/1 with validation error" do

  before do
    @current_organization_or_survey_invitation = mock_model(Organization, :id => 1)
    login_as(@current_organization_or_survey_invitation)
    
    @discussion = mock_model(Discussion, :id => 1, :update_attributes => false, :errors => mock('full_messages', :full_messages => ['error_messages']))
    @survey = mock_model(Survey, :id => 1)
    
    @organization_discussions_proxy = mock('organization discussions proxy', :find => @discussion)
    @current_organization_or_survey_invitation.stub!(:discussions).and_return(@organization_discussions_proxy)
    
    Survey.stub!(:find).and_return(@survey)
    
    @params = {:survey_id => @survey.id, :id => @discussion.id, :discussion => {:subject => 'subject', :body => 'body'}}
  end
  
  def do_put
    @request.env["HTTP_ACCEPT"] = "text/javascript"
    put :update, @params
  end
  
  it "should render the error" do
    do_put
    response.body.should eql('error_messages')
  end
  
end

describe DiscussionsController, " handling DELETE /discussions/1" do
  
  before do
    @current_organization_or_survey_invitation = mock_model(Organization, :id => 1)
    login_as(@current_organization_or_survey_invitation)
    
    @discussion = mock_model(Discussion, :id => 1)
    @discussion.stub!(:destroy)
    @survey = mock_model(Survey, :id => 1)
    
    @organization_discussions_proxy = mock('organization discussions proxy', :find => @discussion)
    @current_organization_or_survey_invitation.stub!(:discussions).and_return(@organization_discussions_proxy)
    
    Survey.stub!(:find).and_return(@survey)
    
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_delete
    delete :destroy, @params
  end
    
  it "should require being logged in" do
    controller.should_receive(:login_or_survey_invitation_required)
    do_delete
  end
  
  it "should find the discussion requested" do
    @organization_discussions_proxy.should_receive(:find).and_return(@discussion)
    do_delete
  end
  
  it "should destory the discussion requested" do
    @discussion.should_receive(:destroy)
    do_delete
  end
  
  it "should redirect discussions page for the related survey upon success" do
    do_delete
    response.should redirect_to(survey_path(@survey)) 
  end
  
end

describe DiscussionsController, "handling PUT /discussions/1/report" do
  
  before do
    @current_organization_or_survey_invitation = mock_model(Organization, :id => 1)
    login_as(@current_organization_or_survey_invitation)
    
    @discussion = mock_model(Discussion, :id => 1, :times_reported => 0)
    @discussion.stub!(:increment!).with(:times_reported).and_return(true)

    @survey_discussions_proxy = mock('survey discussions proxy', :find => @discussion)
    @survey = mock_model(Survey, :id => 1, :discussions => @survey_discussions_proxy)
    
    Survey.stub!(:find).and_return(@survey)
    
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_put
    put :report, @params
  end
   
  it "should require being logged in" do
    controller.should_receive(:login_or_survey_invitation_required)
    do_put
  end
  
  it "should find the discussion requested" do
    @survey_discussions_proxy.should_receive(:find).and_return(@discussion)
    do_put
  end
  
  it "should increase the number of times reported" do
    @discussion.should_receive(:increment!).with(:times_reported)
    do_put
  end
  
  it "should redirect to the discussion page" do
    do_put
    response.should redirect_to(survey_path(@survey))  
  end
  
  it "should flash a success message upon success" do
    do_put
    flash[:notice].should eql('The discussion was reported successfully.')    
  end  
    
end

