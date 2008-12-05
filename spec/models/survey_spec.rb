require File.dirname(__FILE__) + '/../spec_helper'

module SurveySpecHelper
  def valid_survey_attributes
    {
      :job_title => 'That guy who yells "Scalpel, STAT!"',
      :end_date => Time.now + 1.week,
      :sponsor => mock_model(Organization)
    }
  end
end

describe Survey do
  include SurveySpecHelper
  
  before do
    @survey = Survey.new
  end
  
  it "should be valid" do
    @survey.attributes = valid_survey_attributes
    @survey.should be_valid
  end
  
  it "should belong to a sponsor" do
    Survey.reflect_on_association(:sponsor).should_not be_nil
  end
  
  it "should have many discussions" do
    Survey.reflect_on_association(:discussions).should_not be_nil
  end
  
  it "should have many survey invitations" do
    Survey.reflect_on_association(:invitations).should_not be_nil
  end
  
  it "should have many external survey invitations" do
    Survey.reflect_on_association(:external_invitations).should_not be_nil
  end
  
  it "should have many questions" do
    Survey.reflect_on_association(:questions).should_not be_nil
  end
  
  it "should have many responses" do
    Survey.reflect_on_association(:responses).should_not be_nil
  end
  
  it "should have many survey subscriptions" do
    Survey.reflect_on_association(:subscriptions).should_not be_nil
  end
  
  it "should have many subscriped organiations" do
    Survey.reflect_on_association(:subscribed_organizations).should_not be_nil
  end
  
  it "should be invalid without an end date to be specified" do
    @survey.attributes = valid_survey_attributes.except(:end_date)
    @survey.should have(1).error_on(:end_date)
  end
  
  it "should be invalid with a job title longer then 128 characters" do
    @survey.attributes = valid_survey_attributes.with(:job_title => 'a'*129)
    @survey.should have(1).error_on(:job_title)
  end
  
  it "should be invalid without a job title" do
    @survey.attributes = valid_survey_attributes.except(:job_title)
    @survey.should have_at_least(1).error_on(:job_title)
  end
  
  it "should be invalid without a sponsor" do
    @survey.attributes = valid_survey_attributes.except(:sponsor)
    @survey.should have(1).error_on(:sponsor)
  end
  
  it "should be closed if the current time is after the end date" do
    @survey.end_date = Time.now - 1.week
    @survey.should be_closed
  end
  
  it "should be open if the current time is before the end date" do
    @survey.end_date = Time.now + 1.week
    @survey.should be_open
  end
  
  it "should have a survey subscription for the survey sponsor after its created" do
    @survey = Survey.create(valid_survey_attributes)
    sub = @survey.subscriptions.detect { |s| s.organization_id = valid_survey_attributes[:sponsor].id} 
    sub.should_not be_nil
    sub.relationship.should == "sponsor"
    @survey.destroy
  end

  it "should have a rerun deadline of 21 days after it is created" do
    @survey.created_at = Time.now
    @survey.rerun_deadline.should == @survey.created_at + 21.days
  end

  it "should determine the number of days until the rerun deadline" do
    @survey.created_at = Time.now
    @survey.days_until_rerun_deadline.should == 21
  end
  
  it "should be invalid on update without questions" do
    @survey = Survey.create(valid_survey_attributes)
    @survey.update_attributes(nil)
    @survey.should have_at_least(1).error_on(:questions)
  end
end

describe Survey, "that is pending" do
  before do
    @survey = Survey.new(valid_survey_attributes)
  end
  
  it "should transition to running once billing information is received" do
    @survey.billing_info_received!
    @survey.should be_running
  end
end

describe Survey, "that is stalled" do
  before do
    @survey = Survey.new(valid_survey_attributes.with(:end_date => Time.now - 1.day))
    @survey.billing_info_received!
    @survey.finish!
  end
  
  it "should transition to stalled once the survey in finished" do
    @survey.should be_stalled
  end
  
  it "should not rerun if the end date is in the past" do
    @survey.rerun!
    @survey.should be_stalled
  end
  
  it "should rerun if end date is in the future" do
    @survey.days_running = 3
    @survey.rerun!
    @survey.should be_running
  end
  
  it "should not rerun if the survey if the end date would be beyond 21 days from creation" do
    @survey.created_at = @survey.end_date - 18.days
    @survey.days_running = 3
    @survey.rerun!
    @survey.should be_stalled
  end
end

describe Survey, "maximum days to rerun" do
  before do
    @survey = Survey.new(valid_survey_attributes.with(:end_date => Time.now + 1.day, :created_at => Time.now))
  end
  
  it "should not exceed 7 days even when more days are available" do
    @survey.created_at = Time.now
    @survey.maximum_days_to_rerun.should == 7 
  end

  it "should be the number of days before the run limit if the run limit is imminent" do
    @survey.created_at = Time.now - 20.days
    @survey.maximum_days_to_rerun.should == 1
  end
end

describe Survey, "that is ready to be billed" do
  before do
    @survey = Survey.new(valid_survey_attributes)
    @survey.aasm_state = 'running'
    @survey.save!
    Gateway.stub!(:bill_survey_sponsor).and_return(true)
  end
  
  it "should be finished if there are enough responses and billing is successful" do
    @survey.stub!(:enough_responses?).and_return(true)
    @survey.finish!
    
    @survey.should be_finished
  end

  it "should transition to billing error if there are enough responses but we couldn't bill the sponsor" do
    @survey.stub!(:enough_responses?).and_return(true)
    Gateway.stub!(:bill_survey_sponsor).and_raise(Exceptions::GatewayException.new("Billing fubar"))
    @survey.finish!
    
    @survey.should be_billing_error
  end

  it "should transition to stalled if there are not enough responses" do
    @survey.stub!(:enough_responses).and_return(false)
    @survey.finish!

    @survey.should be_stalled
  end

  it "should not attempt to bill the sponsor when there are not enough responses" do
    @survey.stub!(:enough_responses).and_return(false)
    Gateway.should_not_receive(:bill_survey_sponsor)
    @survey.finish!
  end
end
