require File.dirname(__FILE__) + '/../spec_helper'

describe DiscussionsController, "#route_for" do
  it "should map { :controller => 'discussions', :action => 'index' } to surveys/1/discussions" do
    route_for(:controller => "discussions", :action => "index", :survey_id => '1') .should == "/surveys/1/discussions"
  end

  it "should map { :controller => 'discussions', :action => 'update', :id => '1'} to surveys/1/discussions/1" do
    route_for(:controller => "discussions", :action => "update", :id => '1', :survey_id => '1').should == {:path => "/surveys/1/discussions/1", :method => :put}
  end

  it "should map { :controller => 'discussions', :action => 'report', :id => '1'} to surveys/1/discussions/1/report" do
    route_for(:controller => "discussions", :action => "report", :id => '1', :survey_id => '1').should == "/surveys/1/discussions/1/report"
  end
end

describe DiscussionsController, " handling POST /discussions" do
  before do
    @organization = Factory(:organization)
    login_as(@organization)
    
    @survey = Factory(:survey)

    @params = {:survey_id => @survey.id, :discussion => Factory.attributes_for(:discussion, :survey => @survey)}
  end
  
  def do_post
    post :create, @params
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_or_survey_invitation_required)
    do_post
  end
  
  it "should create a new discussion" do
    lambda { do_post }.should change(Discussion, :count).by(1)
  end
  
  it "should redirect to the survey show page upon success" do
    do_post
    response.should redirect_to(survey_path(@survey))
  end
  
end

describe DiscussionsController, " handling POST /discussions with validation error" do

  before do
    @organization = Factory(:organization)
    login_as(@organization)
    
    @survey = Factory(:survey)

    @params = { :survey_id => @survey.id,
                :discussion => Factory.attributes_for(:discussion).except(:subject) }
  end
  
  def do_post
    post :create, @params
  end
  
  it "should redirect to the survey show page" do
    do_post
    response.should redirect_to(survey_path(@survey))
  end

  it "should assign the invalid discussion to flash" do
    do_post
    flash[:discussion].should_not be_nil
  end
  
end

describe DiscussionsController, " handling PUT /discussions/1" do
  before do
    @organization = Factory(:organization)
    login_as(@organization)
    
    @survey = Factory(:survey)
    @discussion = Factory(:discussion, :survey => @survey, :responder => @organization)

    @params = { :survey_id => @survey.id,
                :id => @discussion.id,
                :discussion => Factory.attributes_for(:discussion).with(:body => "Rampage").except(:survey, :responder) }
  end
  
  def do_put
    put 'update', @params.merge(:format => 'js')
    @discussion.reload
  end
  
  it "should require being logged in" do
    controller.should_receive(:login_or_survey_invitation_required)
    do_put
  end
  
  it "should update the selected discussion" do
    do_put
    @discussion.body.should == "Rampage"
  end
     
  it "should return the updated text" do
    do_put
    response.body.should == '<p>Rampage</p>'
  end
end

describe DiscussionsController, " handling PUT /discussions/1 with validation error" do
  before do
    @organization = Factory(:organization)
    login_as(@organization)
    
    @survey = Factory(:survey)
    @discussion = Factory(:discussion, :survey => @survey, :responder => @organization)

    @params = { :survey_id => @survey.id,
                :id => @discussion.id,
                :discussion => Factory.attributes_for(:discussion).with(:subject => '').except(:survey, :responder) }
  end
  
  def do_put
    put :update, @params.merge(:format => 'js')
  end
  
  it "should render the error" do
    do_put
    response.body.should == "Subject can't be blank"
  end
end

describe DiscussionsController, "handling PUT /discussions/1/report" do
  before do
    @organization = Factory(:organization)
    login_as(@organization)

    @survey = Factory(:survey)
    @discussion = Factory(:discussion, :survey => @survey)

    @params = { :survey_id => @survey.id,
                :id => @discussion.id }
  end
  
  def do_put
    put :report, @params
    @discussion.reload
  end
   
  it "should require being logged in" do
    controller.should_receive(:login_or_survey_invitation_required)
    do_put
  end
  
  it "should increase the number of times reported" do
    lambda { do_put }.should change(@discussion, :times_reported).by(1)
  end
  
  it "should redirect to the discussion page" do
    do_put
    response.should redirect_to(survey_path(@survey))  
  end
  
  it "should flash a success message upon success" do
    do_put
    flash[:notice].should eql('The discussion was reported')    
  end  
end

