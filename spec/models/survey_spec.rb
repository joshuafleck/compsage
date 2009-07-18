require File.dirname(__FILE__) + '/../spec_helper'

describe Survey do
  
  before do
    @survey = valid_survey
  end
  
  it "should be valid" do
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
  
  it "should be invalid with a job title longer then 128 characters" do
    @survey.save
    @survey[:job_title] = 'a'*129
    @survey.should have(1).error_on(:job_title)
  end
  
  it "should be invalid without a job title" do
    @survey.save
    @survey[:job_title]= nil
    @survey.should have_at_least(1).error_on(:job_title)
  end
  
  it "should be invalid without a sponsor" do
    @survey.sponsor = nil
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
    @survey.save!
    sub = @survey.subscriptions.detect { |s| s.organization_id = valid_survey_attributes[:sponsor].id} 
    sub.should_not be_nil
    sub.relationship.should == "sponsor"
    @survey.destroy
  end

  it "should have a extension deadline of 21 days after it is created" do
    @survey.start_date = Time.now
    @survey.extension_deadline.should == @survey.start_date + 21.days
  end

  it "should determine the number of days until the extension deadline" do
    @survey.start_date = Time.now
    @survey.days_until_extension_deadline.should == 21
  end
  
  it "should update the end date when the number of days running is changed" do
    current_time = Time.now
    @survey.start_date = current_time
    @survey.end_date = current_time
    @survey.aasm_state = 'running'
    @survey.days_to_extend = 10
    @survey.save!
    @survey.end_date.should eql(current_time + 10.days)
    @survey.destroy
  end  
  
  it "should be invalid without questions" do
    @survey = Survey.create(valid_survey_attributes)
    @survey.should_not be_valid
    @survey.destroy
  end
  
  it "should update the aasm_state_number on save" do
    @survey.aasm_state = 'running'
    @survey.save!
    @survey.aasm_state_number.should eql(1)
    @survey.aasm_state = 'stalled'
    @survey.save!
    @survey.aasm_state_number.should eql(2)
    @survey.destroy
  end

end

describe Survey, "that is pending" do
  before do
    @survey = valid_survey
  end
  
  it "should transition to running once billing information is received" do
    @survey.billing_info_received!
    @survey.should be_running
  end

  it "should send all of its invitations when finalized" do
    inv = @survey.invitations.build
    external_inv = @survey.external_invitations.build
    inv.should_receive(:send_invitation!).and_return(true)
    external_inv.should_receive(:send_invitation!).and_return(true)

    @survey.billing_info_received!
  end
end

describe Survey, "that is stalled" do
  before(:each) do
    @survey = valid_survey(valid_survey_attributes)
    @survey.billing_info_received!
    @survey.start_date = Time.now - 7.days
    @survey.end_date = Time.now - 1.second
    @survey.finish!
  end
  
  it "should transition to stalled once the survey in finished" do
    @survey.should be_stalled
  end
  
  it "should rerun" do
    @survey.days_to_extend = 3
    @survey.save!
    @survey.rerun!
    @survey.should be_running
  end
  
  it "should not rerun if the survey if the end date would be beyond 21 days from creation" do
    @survey.start_date = @survey.end_date - 19.days
    @survey.days_running = 3
    @survey.rerun!
    @survey.should be_stalled
  end

end

describe Survey, "maximum days to extend" do
  before do
    @survey = valid_survey(valid_survey_attributes.with(:end_date => Time.now + 1.day, :start_date => Time.now))
  end
  
  it "should not exceed 7 days even when more days are available" do
    @survey.start_date = Time.now
    @survey.maximum_days_to_extend.should == 7 
  end

  it "should be the number of days before the run limit if the run limit is imminent" do
    @survey.start_date = Time.now - 20.days
    @survey.maximum_days_to_extend.should == 1
  end
end

describe Survey, "that is ready to be billed" do
  before do
    @survey = valid_survey
    @survey.aasm_state = 'running'
    @survey.end_date = Date.today - 1.day
    @survey.save!
    Gateway.stub!(:bill_survey_sponsor).and_return(true)
  end
  
  after do
    @survey.destroy
  end
  
  it "should be finished if there are enough responses and billing is successful" do
    @survey.stub!(:full_report?).and_return(true)
    @survey.finish!
    
    @survey.should be_finished
  end

  it "should transition to billing error if there are enough responses but we couldn't bill the sponsor" do
    @survey.stub!(:full_report?).and_return(true)
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

describe Survey, "that is being cancelled (destroyed)" do
  before do 
    @org_1 = Organization.create!(valid_organization_attributes.with(:email => "test@example.org"))
    @org_2 = Organization.create!(valid_organization_attributes.with(:email => "test2@example.org"))
    
    @survey = valid_survey(valid_survey_attributes.with(:sponsor => @org_1))
    @survey.aasm_state = 'stalled'
    @survey.save!
    
    @inv_1 = @survey.external_invitations.create!(:email => "test2@example.org", :organization_name => "name", :inviter => @survey.sponsor)
    
    @participation_1 = @survey.participations.create!(
      :participant => @org_2,
      :responses => [mock_model(Response, :question_id => 1, :valid? => true, :[]= => true, :save => true)])
    @participation_2 = @survey.participations.create!(
      :participant => @inv_1, 
      :responses => [mock_model(Response, :question_id => 1, :valid? => true, :[]= => true, :save => true)])
  end
  
  after do
    @org_1.destroy
    @org_2.destroy
  end

  it "should delete all the participations" do
    @survey.destroy
    @survey.participations.should be_empty
  end

  it "should delete all invitations" do
    @survey.destroy
    @survey.invitations.should be_empty
    @survey.external_invitations.should be_empty
  end
end
