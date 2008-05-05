require File.dirname(__FILE__) + '/../spec_helper'

describe DiscussionsController, "#route_for" do

  it "should map { :controller => 'discussions', :action => 'index' } to surveys/1/discussions" do
    route_for(:controller => "discussions", :action => "index", :survey_id => 1) .should == "/surveys/1/discussions"
  end

  it "should map { :controller => 'discussions', :action => 'new' } to surveys/1/discussions/new" do
    route_for(:controller => "discussions", :action => "new", :survey_id => 1).should == "/surveys/1/discussions/new"
  end

  it "should map { :controller => 'discussions', :action => 'edit', :id => 1 } to surveys/1/discussions/1/edit" do
    route_for(:controller => "discussions", :action => "edit", :id => 1, :survey_id => 1).should == "/surveys/1/discussions/1/edit"
  end

  it "should map { :controller => 'discussions', :action => 'update', :id => 1} to surveys/1/discussions/1" do
    route_for(:controller => "discussions", :action => "update", :id => 1, :survey_id => 1).should == "/surveys/1/discussions/1"
  end

  it "should map { :controller => 'discussions', :action => 'destroy', :id => 1} to surveys/1/discussions/1" do
    route_for(:controller => "discussions", :action => "destroy", :id => 1, :survey_id => 1).should == "/surveys/1/discussions/1"
  end

  it "should map { :controller => 'discussions', :action => 'report', :id => 1} to surveys/1/discussions/1/report" do
    route_for(:controller => "discussions", :action => "report", :id => 1, :survey_id => 1).should == "/surveys/1/discussions/1/report"
  end

end

describe DiscussionsController, " handling GET discussions" do
  
  before do
    @current_organization_or_invitation = mock_model(Organization)
    login_as(@current_organization_or_invitation)
    
    @discussion = mock_model(Discussion)
    @survey = mock_model(Survey, :id => 1, :job_title => 'Software Engineer')
    @survey.stub!(:discussions).and_return([@discussion])
    
    Survey.stub!(:find).and_return(@survey)
    
    @params = {:survey_id => @survey.id}
  end
  
  def do_get
    get :index, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_or_invite_required)
    do_get
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render index template" do
    do_get
    response.should render_template("index")
  end
  
  #TODO set threshhold in finder
  it "should find all discussions, under the number of times reported threshold" do
    pending
    @survey.should_receive(:discussions).and_return([@discussion])
    do_get
  end
  
  it "should assign the found discussion for the view"do
    do_get
    assigns[:discussions].should eql([@discussion])
  end
  
  it "should support sorting..." do
    pending
  end
    
  it "should support pagination..." do
    pending
  end
  
end

describe DiscussionsController, " handling GET /discussions.xml" do
  
  before do
    @current_organization_or_invitation = mock_model(Organization)
    login_as(@current_organization_or_invitation)
    
    @discussion = mock_model(Discussion, :to_xml => "XML")
    @discussions = [@discussion]
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
    controller.should_receive(:login_or_invite_required)
    do_get
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find all discussion, under the number of times reported thresholds" do
    @survey.should_receive(:discussions).and_return(@discussions)
    do_get
  end
  
  it "should render the found discussions as XML" do
    @discussions.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
    
end

describe DiscussionsController, " handling GET /discussions/new" do

  before do
    @current_organization_or_invitation = mock_model(Organization)
    login_as(@current_organization_or_invitation)
    
    @discussion = mock_model(Discussion)
    @survey = mock_model(Survey, :id => 1, :job_title => 'Software Engineer')
    
    Survey.stub!(:find).and_return(@survey)
    Discussion.stub!(:new).and_return(@discussion)
    
    @params = {:survey_id => @survey.id}
  end
  
  def do_get
    get :new, @params
  end
   
  it "should require being logged in" do
    controller.should_receive(:login_or_invite_required)
    do_get
  end
   
  it "should be successful"do
    do_get
    response.should be_success
  end
  
  it "should render new template" do
    do_get
    response.should render_template('new')
  end
  
  it "should create a new discussion" do
    Discussion.should_receive(:new).and_return(@discussion)
    do_get
  end
  
  it "should fail if the external survey invitation does not correspond to this survey" do
    pending
  end
end

describe DiscussionsController, " handling GET /discussions/1/edit" do

  before do
    @current_organization_or_invitation = mock_model(Organization)
    login_as(@current_organization_or_invitation)
    
    @discussion = mock_model(Discussion, :id => 1, :topic => "Discussion topic")
    @survey = mock_model(Survey, :id => 1, :job_title => "Software Engineer")
    
    @organization_discussions_proxy = mock('organization discussions proxy', :find => @discussion)
    @current_organization_or_invitation.stub!(:discussions).and_return(@organization_discussions_proxy)
    
    Survey.stub!(:find).and_return(@survey)
    
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_get
    get :edit, @params
  end
    
  it "should require being logged in" do
    controller.should_receive(:login_or_invite_required)
    do_get
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render the edit template" do
    do_get
    response.should render_template('edit')
  end
  
  it "should find the discussion requested" do
    @organization_discussions_proxy.should_receive(:find).and_return(@discussion)
    do_get
  end
  
  it "should assign the found discussion to the view" do
    do_get
    assigns[:discussion].should eql(@discussion)
  end
  
end

describe DiscussionsController, " handling POST /discussions" do

  before(:each) do
    @current_organization_or_invitation = mock_model(Organization)
    login_as(@current_organization_or_invitation)
    
    @survey = mock_model(Survey, :id => 1)
    @discussion = mock_model(Discussion, :id => 1, :save! => true)  
    @discussions = [@discussion] 
    
    @survey_discussions_proxy = mock('survey discussions proxy', :discussions => @discussions)
    @survey_discussions_proxy.stub!(:<<, true)
    @organization_discussions_proxy = mock('organization discussions proxy', :new => @discussion)
    @current_organization_or_invitation.stub!(:discussions).and_return(@organization_discussions_proxy)
    @survey.stub!(:discussions).and_return(@survey_discussions_proxy)
    
    Survey.stub!(:find).and_return(@survey)
    
    @params = {:survey_id => @survey.id}
  end
  
  def do_post
    post :create, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_or_invite_required)
    do_post
  end
  
  it "should create a new discussion" do
    @organization_discussions_proxy.should_receive(:new).and_return(@discussion)
    do_post
  end
  
  it "should add the discussion to the survey" do
    @survey_discussions_proxy.should_receive(:<<)
    do_post
  end
  
  it "should redirect to the discussion index page upon success" do
    do_post
    response.should redirect_to(survey_discussions_path(@survey))
  end
  
  it "should flash a message indicating succcess" do
    do_post
    flash[:notice].should eql("Your discussion was created successfully.")
  end
  
  it "should assign the parent discussion if this is a reply" do
    #Still thinking about how this should be implemented
    pending
  end
  
  it "should fail if the external survey invitation does not correspond to this survey" do
    pending
  end
end

describe DiscussionsController, " handling PUT /discussions/1" do

  before do
    @current_organization_or_invitation = mock_model(Organization, :id => 1)
    login_as(@current_organization_or_invitation)
    
    @discussion = mock_model(Discussion, :id => 1, :update_attributes! => true)
    @survey = mock_model(Survey, :id => 1)
    
    @organization_discussions_proxy = mock('organization discussions proxy', :find => @discussion)
    @current_organization_or_invitation.stub!(:discussions).and_return(@organization_discussions_proxy)
    
    Survey.stub!(:find).and_return(@survey)
    
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_put
    put :update, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_or_invite_required)
    do_put
  end
  
  it "should find the discussion requested" do
    @organization_discussions_proxy.should_receive(:find).and_return(@discussion)
    do_put    
  end
  
  it "should update the selected discussion" do
    @discussion.should_receive(:update_attributes!)
    do_put
  end
     
  it "should redirect to the discussion page for related survey upon success" do
    do_put
    response.should redirect_to(survey_discussions_path(@survey))
  end
  
  it "should flash a message regarding the success of the edit" do
    do_put
    flash[:notice].should == "Your discussion was updated successfully."
  end
  
end

describe DiscussionsController, " handling DELETE /discussions/1" do
  
  before do
    @current_organization_or_invitation = mock_model(Organization, :id => 1)
    login_as(@current_organization_or_invitation)
    
    @discussion = mock_model(Discussion, :id => 1)
    @discussion.stub!(:destroy)
    @survey = mock_model(Survey, :id => 1)
    
    @organization_discussions_proxy = mock('organization discussions proxy', :find => @discussion)
    @current_organization_or_invitation.stub!(:discussions).and_return(@organization_discussions_proxy)
    
    Survey.stub!(:find).and_return(@survey)
    
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_delete
    delete :destroy, @params
  end
    
  it "should require being logged in" do
    controller.should_receive(:login_or_invite_required)
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
  
  it "should destroy the children of the discussion" do
    pending
  end
  
  it "should redirect discussions page for the related survey upon success" do
    do_delete
    response.should redirect_to(survey_discussions_path(@survey)) 
  end
  
  it "should flash a message regarding the success of the action" do
    do_delete
    flash[:notice].should eql('The discussion was deleted successfully.')    
  end  
 end

describe DiscussionsController, "handling PUT /discussions/1/report" do
  
  before do
    @current_organization_or_invitation = mock_model(Organization, :id => 1)
    login_as(@current_organization_or_invitation)
    
    @discussion = mock_model(Discussion, :id => 1, :times_reported => 0)
    @discussion.stub!(:increment!).with(:times_reported)

    @survey_discussions_proxy = mock('survey discussions proxy', :find => @discussion)
    @survey = mock_model(Survey, :id => 1, :discussions => @survey_discussions_proxy)
    
    Survey.stub!(:find).and_return(@survey)
    
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_put
    put :report, @params
  end
   
  it "should require being logged in" do
    controller.should_receive(:login_or_invite_required)
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
  
  it "should send an email reporting the abuse when the number of times reported is greater then the threshold" do
    pending
  end
  
  it "should redirect to the discussion page" do
    do_put
    response.should redirect_to(survey_discussions_path(@survey))  
  end
  
  it "should flash a success message upon success" do
    do_put
    flash[:notice].should eql('The discussion was reported successfully.')    
  end  
    
end

