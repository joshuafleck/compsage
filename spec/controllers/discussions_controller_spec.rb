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
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    @discussion = mock_model(Discussion, :id => 1, :to_xml => "XML")
    @survey = mock_model(Survey, :id => 1)
    @survey.stub!(:discussions).and_return([@discussion])
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id}
  end
  
  def do_get
    get :index, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
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
  
  #it "should only render if the user is invited to, or sponsors the related survey"
  #JF not sure if the above spec if valid anymore since surveys are public
end

describe DiscussionsController, " handling GET /discussions.xml" do
  
  before do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    @discussion = mock_model(Discussion, :id => 1, :to_xml => "XML")
    @survey = mock_model(Survey, :id => 1)
    @survey.stub!(:discussions).and_return([@discussion])
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id}
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_required)
    do_get
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find all discussion, under the number of times reported thresholds" do
    @survey.should_receive(:discussions).and_return([@discussion])
    do_get
  end
  
  it "should render the found discussions as XML" do
    @discussion.should_receive(:to_xml).exactly(2).times.and_return("XML")
    do_get
    response.body.should == [@discussion].to_xml
  end
  
  #it "should only render if the user is invited to, or sponsors the related survey"
  #JF see above
  
end

describe DiscussionsController, " handling GET /discussions/new" do

  before do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    @survey = mock_model(Survey, :id => 1)
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id}
  end
  
  def do_get
    get :new, @params
  end
  
  it "should be successful"do
    do_get
    response.should be_success
  end
  
  it "should render new template" do
    do_get
    response.should render_template('new')
  end
  
  #it "should only render if the user is invited to, or sponsors the related survey"
  
end

describe DiscussionsController, " handling GET /discussions/1/edit" do

  before do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    @discussion = mock_model(Discussion, :id => 1, :responder => @current_organization)
    @survey_discussions_proxy = mock('survey discussions proxy', :find => @discussion)
    @survey = mock_model(Survey, :id => 1, :discussions => @survey_discussions_proxy)
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_get
    get :edit, @params
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render the edit template if the current organization owns the discussion" do
    do_get
    response.should render_template('edit')
  end
  
  it "should find the discussion requested" do
    @survey_discussions_proxy.should_receive(:find).and_return(@discussion)
    do_get
  end
  
  it "should assign the found discussion to the view" do
    do_get
    assigns[:discussion].should eql(@discussion)
  end
  
end

describe DiscussionsController, " handling GET /discussions/1/edit" do

  before do
    @current_organization = mock_model(Organization, :id => 1)
    login_as(@current_organization)
    @discussion_organization = mock_model(Organization, :id => 2)
    @discussion = mock_model(Discussion, :id => 1, :responder => @discussion_organization)
    @survey_discussions_proxy = mock('survey discussions proxy', :find => @discussion)
    @survey = mock_model(Survey, :id => 1, :discussions => @survey_discussions_proxy)
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_get
    get :edit, @params
  end
  
  it "should raise an error if the current organization does not own the discussion" do
    lambda{ do_get }.should raise_error("You do not have the rights to access this page.")
  end
  
  it "should raise an error if the current invitation does not own the discussion" do
    pending
  end  
  
end

describe DiscussionsController, " handling POST /discussions" do

  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    @survey = mock_model(Survey, :id => 1)
    @discussion = mock_model(Discussion, :id => 1, :save => true, :errors => [])
    @discussion.stub!(:new_record?).and_return(true)
    Discussion.stub!(:new).and_return(@discussion)
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id, :title => 'Discuss this', :body => 'Discussion about this'}
  end
  
  def do_post
    post :create, @params
  end

  it "should create a new discussion" do
    Discussion.should_receive(:new).and_return(@discussion)
    do_post
  end
  
  it "should redirect to the discussion index page upon success" do
    do_post
    response.should redirect_to(survey_discussions_path(@survey))
  end
  
  it "should flash a message indicating succcess" do
    do_post
    flash[:notice].should eql("Discussion was created successfully!")
  end
  
  it "should assign the parent discussion if this is a reply" do
    #Still thinking about how this should be implemented
    pending
  end
  
end

describe DiscussionsController, " handling POST /discussions" do

  before(:each) do
    @current_organization = mock_model(Organization)
    login_as(@current_organization)
    @survey = mock_model(Survey, :id => 1)
    @discussion = mock_model(Discussion, :id => 1, :save => true, :errors => ['Error!'])
    @discussion.stub!(:new_record?).and_return(true)
    Discussion.stub!(:new).and_return(@discussion)
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id}
  end
  
  def do_post
    post :create, @params
  end

  it "should render the 'new' view upon failure" do
     do_post
     response.should render_template('discussions/new')
   end
   
end

describe DiscussionsController, " handling PUT /discussions/1" do

  before do
    @current_organization = mock_model(Organization, :id => 1)
    login_as(@current_organization)
    @discussion = mock_model(Discussion, :id => 1, :errors => [], :responder => @current_organization, :times_reported => 1)
    @discussion.stub!(:update_attributes).and_return(true)
    @survey_discussions_proxy = mock('survey discussions proxy', :find => @discussion)
    @survey = mock_model(Survey, :id => 1, :discussions => @survey_discussions_proxy)
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_put
    put :update, @params
  end

  it "should find the discussion requested" do
    pending
  #  @survey_discussions_proxy.should_receive(:find).and_return(@discusion)
  #  do_put    
  end
  
  it "should update the selected discussion" do
    @discussion.should_receive(:update_attributes)
    do_put
  end
     
  it "should redirect to the discussion page for related survey upon success" do
    do_put
    response.should redirect_to(survey_discussions_path(@survey))
  end
  
end

describe DiscussionsController, " handling PUT /discussions/1" do

  before(:each) do
    @current_organization = mock_model(Organization, :id => 1)
    login_as(@current_organization)
    @discussion = mock_model(Discussion, :id => 1, :update_attributes => true, :responder => mock(Organization, :id => 2))
    @survey_discussions_proxy = mock('survey discussions proxy', :find => @discussion)
    @survey_discussions_proxy.stub!(:find).and_return(@discussion)
    @survey = mock_model(Survey, :id => 1, :discussions => @survey_discussions_proxy)
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_put
    put :update, @params
  end
  
  it "should raise an error if the current organization does not own the discussion" do
    lambda{ do_put }.should raise_error("You do not have the rights to access this page.")
  end
     
  it "should raise an error if the current invitation does not own the discussion" do
    pending
  end 
end

describe DiscussionsController, " handling PUT /discussions/1" do

  before(:each) do
    @current_organization = mock_model(Organization, :id => 1)
    login_as(@current_organization)
    @discussion = mock_model(Discussion, :id => 1, :update_attributes => false, :responder => @current_organization)
    @survey_discussions_proxy = mock('survey discussions proxy', :find => @discussion)
    @survey_discussions_proxy.stub!(:find).and_return(@discussion)
    @survey = mock_model(Survey, :id => 1, :discussions => @survey_discussions_proxy)
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_put
    put :update, @params
  end
  
  it "should render the edit template upon failure" do
    do_put
    response.should render_template('discussions/edit')
  end
  
end

describe DiscussionsController, " handling DELETE /discussions/1" do
  
  before do
    @current_organization = mock_model(Organization, :id => 1)
    login_as(@current_organization)
    @discussion = mock_model(Discussion, :id => 1, :errors => [], :responder => @current_organization, :times_reported => 1)
    @discussion.stub!(:destroy).and_return(@discussion)
    @survey_discussions_proxy = mock('survey discussions proxy', :find => @discussion)
    @survey = mock_model(Survey, :id => 1, :discussions => @survey_discussions_proxy)
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_delete
    delete :destroy, @params
  end
  
  it "should find the discussion requested" do
    @survey_discussions_proxy.should_receive(:find).and_return(@discussion)
    do_delete
  end
  
  it "should destory the discussion requested" do
    @discussion.should_receive(:destroy).and_return(@discussion)
    do_delete
  end
  
  it "should destroy the children of the discussion" do
    pending
  end
  
  it "should redirect discussions page for the related survey upon success" do
    do_delete
    response.should redirect_to(survey_discussions_path(@survey))
     flash[:notice].should eql('Discussion was successfully deleted.')    
  end
 end

describe DiscussionsController, " handling DELETE /discussions/1" do
  
  before do
    @current_organization = mock_model(Organization, :id => 1)
    login_as(@current_organization)
    @discussion = mock_model(Discussion, :id => 1, :errors => ['Error'], :responder => @current_organization, :times_reported => 1)
    @discussion.stub!(:destroy).and_return(@discussion)
    @survey_discussions_proxy = mock('survey discussions proxy', :find => @discussion)
    @survey = mock_model(Survey, :id => 1, :discussions => @survey_discussions_proxy)
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_delete
    delete :destroy, @params
  end
  
  it "should flash an error upon failure" do
    do_delete
    response.should redirect_to(survey_discussions_path(@survey))
     flash[:notice].should eql('Unable to delete discussion. Please try again later.')    
  end
end

describe DiscussionsController, " handling DELETE /discussions/1" do
  
  before do
    @current_organization = mock_model(Organization, :id => 1)
    login_as(@current_organization)
    @discussion = mock_model(Discussion, :id => 1, :errors => [], :responder => mock(Organization,:id => 2), :times_reported => 1)
    @discussion.stub!(:destroy).and_return(@discussion)
    @survey_discussions_proxy = mock('survey discussions proxy', :find => @discussion)
    @survey = mock_model(Survey, :id => 1, :discussions => @survey_discussions_proxy)
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_delete
    delete :destroy, @params
  end

  it "should error when the current organization is not the owner of current discussion" do
    lambda{ do_delete }.should raise_error("You do not have the rights to access this page.")
  end
  
  it "should raise an error if the current invitation does not own the discussion" do
    pending
  end
end

describe DiscussionsController, "handling PUT /discussions/1/report" do
  
  before do
    @current_organization = mock_model(Organization, :id => 1)
    login_as(@current_organization)
    @discussion_organization = mock_model(Organization, :id => 2)
    @discussion = mock_model(Discussion, :id => 1, :save => true, :errors => [], :responder => @discussion_organization, :times_reported => 0)
    @discussion.stub!(:increment).with(:times_reported).and_return(@discussion)
    @survey_discussions_proxy = mock('survey discussions proxy', :find => @discussion)
    @survey = mock_model(Survey, :id => 1, :discussions => @survey_discussions_proxy)
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_put
    put :report, @params
  end
  
  it "should find the discussion requested" do
    @survey_discussions_proxy.should_receive(:find).and_return(@discussion)
    do_put
  end
  
  it "should increase the number of times reported" do
    @discussion.should_receive(:increment).with(:times_reported).and_return(@discussion)
    do_put
  end
  
  it "should send an email reporting the abuse when the number of times reported is greater then the threshold" do
    pending
  end
  
  it "should redirect to the discussion page and flash a success message upon success" do
    do_put
    response.should redirect_to(survey_discussions_path(@survey))
     flash[:notice].should eql('Discussion was successfully reported.')    
  end
    
end

describe DiscussionsController, "handling PUT /discussions/1/report" do
  
  before do
    @current_organization = mock_model(Organization, :id => 1)
    login_as(@current_organization)
    @discussion_organization = mock_model(Organization, :id => 2)
    @discussion = mock_model(Discussion, :id => 1, :save => true, :errors => ['Error'], :responder => @discussion_organization, :times_reported => 1)
    @discussion.stub!(:increment).with(:times_reported).and_return(@discussion)
    @survey_discussions_proxy = mock('survey discussions proxy', :find => @discussion)
    @survey = mock_model(Survey, :id => 1, :discussions => @survey_discussions_proxy)
    Survey.stub!(:find).and_return(@survey)
    @params = {:survey_id => @survey.id, :id => @discussion.id}
  end
  
  def do_put
    put :report, @params
  end
  
  it "should redirect to the discussion page and flash an error message upon failure" do
    do_put
    response.should redirect_to(survey_discussions_path(@survey))
     flash[:notice].should eql('Unable to report discussion. Please try again later.')    
  end
  
end
