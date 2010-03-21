require 'spec_helper'

describe Association::SurveysController, "handling get /association/surveys"  do
  before do
    @association  = Factory(:association)
    login_as(@association)

    @survey = Factory(:finished_survey, :association => @association)
  end

  def do_get
    get :index
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should require being an association" do
    controller.should_receive(:association_owner_login_required).and_return(true)
    do_get
  end

  it "should assign the survey to the view" do
    do_get
    assigns[:surveys].should == [@survey]
  end

  it "should render the index template" do
    do_get
    response.should render_template('index')
  end
end

describe Association::SurveysController, "handling put /association/surveys"  do
  before do
    @association  = Factory(:association)
    login_as(@association)

    @survey = Factory(:finished_survey, :association => @association)
    @params = {:id => @survey.id}
  end

  def do_put
    put :update, @params
  end

  it "should update the association billing status" do
    @params[:survey] = {:association_billing_status => 'billed'}
    do_put

    @survey.reload
    @survey.association_billing_status.should == 'billed'
  end

  it "should not update any other fields" do
    @params[:survey] = {:job_title => 'billed'}
    do_put

    @survey.reload
    @survey.job_title.should_not == 'billed'
  end
end

