require File.dirname(__FILE__) + '/../spec_helper'

describe Survey do
  
  before do
    @survey = Factory.build(:survey)
  end
  
  it "should be valid" do
    @survey.should be_valid
  end
  
  it "should belong to a sponsor" do
    Survey.reflect_on_association(:sponsor).should_not be_nil
  end
   
  it "should have one invoice" do
    Survey.reflect_on_association(:invoice).should_not be_nil
  end
   
  it "should have many discussions" do
    Survey.reflect_on_association(:discussions).should_not be_nil
  end
  
  it "should have many survey invitations" do
    Survey.reflect_on_association(:invitations).should_not be_nil
  end
   
  it "should have many invitees" do
    Survey.reflect_on_association(:invitees).should_not be_nil
  end
  
  it "should have many external survey invitations" do
    Survey.reflect_on_association(:external_invitations).should_not be_nil
  end
    
  it "should have many internal and external survey invitations" do
    Survey.reflect_on_association(:internal_and_external_invitations).should_not be_nil
  end
  
  it "should have many questions" do
    Survey.reflect_on_association(:questions).should_not be_nil
  end
   
  it "should have many top level questions" do
    Survey.reflect_on_association(:top_level_questions).should_not be_nil
  end
   
  it "should have many responses" do
    Survey.reflect_on_association(:responses).should_not be_nil
  end
     
  it "should have many participations" do
    Survey.reflect_on_association(:participations).should_not be_nil
  end
  
  it "should have many survey subscriptions" do
    Survey.reflect_on_association(:subscriptions).should_not be_nil
  end
  
  it "should have many subscribed organiations" do
    Survey.reflect_on_association(:subscribed_organizations).should_not be_nil
  end

  it "should belong to an association" do
    Survey.reflect_on_association(:association).should_not be_nil
  end
  
  it "should be invalid with a job title longer then 128 characters" do
    @survey.save
    @survey.job_title = 'a'*129
    @survey.should have(1).error_on(:job_title)
    @survey.destroy
  end
  
  it "should be invalid without a job title" do
    @survey.save
    @survey.job_title = nil
    @survey.should have_at_least(1).error_on(:job_title)
    @survey.destroy
  end
 
  it "should be invalid without questions" do
    @survey.save
    @survey.questions = []
    @survey.should have_at_least(1).error_on(:base)
    @survey.destroy
  end
    
  it "should be invalid without a sponsor" do
    @survey.sponsor = nil
    @survey.should have(1).error_on(:sponsor)
  end
  
  it "should have a survey subscription for the survey sponsor after its created" do
    @survey.save!
    sub = @survey.subscriptions.detect { |s| s.organization == @survey.sponsor} 
    sub.should_not be_nil
    sub.relationship.should == "sponsor"
    @survey.destroy
  end
  
  # TODO: beef up this spec by loading PDQs before the tests
  it "should have default questions added after its created" do
    @survey.should_receive(:add_default_questions)
    @survey.save!
    @survey.destroy
  end
  
  it "should have an invitation for the sponsor after its created" do
    @survey.save
    @survey.invitations.first.should_not be_nil
    @survey.invitations.first.invitee.should == @survey.sponsor
    @survey.destroy
  end
  
  it "should be closed if the current time is after the end date" do
    @survey.end_date = Time.now - 1.week
    @survey.should be_closed
  end
  
  it "should be open if the current time is before the end date" do
    @survey.end_date = Time.now + 1.week
    @survey.should be_open
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
    @survey.days_to_extend.should be_blank
    @survey.destroy
  end  

end

describe Survey, "that is pending" do
  before(:each) do
    @survey = Factory(:pending_survey)
  end
  
  after(:each) do
    @survey.destroy
  end
  
  it "should transition to running once billing information is received" do
    @survey.billing_info_received
    @survey.should be_running
  end
  
  it "should set the end_date" do
    @survey.billing_info_received
    @survey.end_date.should_not be_blank
  end

  it "should send all of its invitations when finalized" do
    invitation = Factory(:pending_survey_invitation, :survey => @survey)
    external_invitation = Factory(:pending_external_survey_invitation, :survey => @survey)
    @survey.billing_info_received
    invitation.reload
    external_invitation.reload
    invitation.should be_sent
    external_invitation.should be_sent
  end
end

describe Survey, "that is stalled" do
  before(:each) do
    @survey = Factory(:stalled_survey)
  end
  
  after(:each) do
    @survey.destroy
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
  
  it "should send a rerun notification to participants" do
    @survey.days_to_extend = 3
    Factory(:participation, :survey => @survey)
    @survey.save!
    Notifier.should_receive(:deliver_survey_rerun_notification_participant)
    @survey.rerun!
  end  
  
  it "should send a rerun notification to non participants" do
    @survey.days_to_extend = 3
    external_invitation = Factory(:sent_external_survey_invitation, :survey => @survey)
    invitation = Factory(:sent_survey_invitation, :survey => @survey)
    @survey.save!
    Notifier.should_receive(:deliver_survey_rerun_notification_non_participant).with(@survey,external_invitation)
    Notifier.should_receive(:deliver_survey_rerun_notification_non_participant).with(@survey,invitation.invitee)
    @survey.rerun!
  end  
    
  it "should not rerun if the survey if the end date would be beyond 21 days from creation" do
    @survey.start_date = @survey.end_date - 19.days
    @survey.days_running = 3
    @survey.rerun
    @survey.should be_stalled
  end

end

describe Survey, "maximum days to extend" do
  before(:each) do
    @survey = Factory(:running_survey, :end_date => Date.today, :start_date => Date.today)
  end
  
  after(:each) do
    @survey.destroy
  end
    
  it "should not exceed 7 days even when more days are available" do
    @survey.start_date = Date.today
    @survey.maximum_days_to_extend.should == 7 
  end

  it "should be the number of days before the run limit if the run limit is imminent" do
    @survey.start_date = Date.today - 20.days
    @survey.maximum_days_to_extend.should == 1
  end
end

describe Survey, "that is ready to be billed" do
  before(:each) do
    @survey = Factory(:running_survey, :end_date => Date.today - 1.day)
    @invoice = Factory(:invoice, :survey => @survey, :payment_type => 'credit')
    Gateway.stub!(:bill_survey_sponsor).and_return(true)
  end
  
  after(:each) do
    @survey.destroy
  end
  
  it "should be finished if there are enough responses and billing is successful" do
    @survey.stub!(:full_report?).and_return(true)
    @survey.finish!
    
    @survey.should be_finished
  end
  
  it "should send a finished notification email to all participants and the sponsor upon completing" do
    @survey.stub!(:full_report?).and_return(true)
    participant = Factory(:sent_external_survey_invitation, :survey => @survey)
    Factory(:participation, :survey => @survey, :participant => participant)
    Notifier.should_receive(:deliver_survey_results_available_notification).with(@survey, participant)
    Notifier.should_receive(:deliver_survey_results_available_notification).with(@survey, @survey.sponsor)
    @survey.finish!
  end   
   
  it "should send a credit card receipt email upon completing" do
    pending
  end   
   
  it "should send an invoice email upon completing" do
    @survey.stub!(:full_report?).and_return(true)
    @invoice.payment_type = 'invoice'
    @invoice.save
    Notifier.should_receive(:deliver_invoice).with(@survey)
    @survey.finish!
  end   

  it "should transition to billing error if there are enough responses but we couldn't bill the sponsor" do
    @survey.stub!(:full_report?).and_return(true)
    Gateway.stub!(:bill_survey_sponsor).and_raise(Exceptions::GatewayException.new("Billing fubar"))
    @survey.finish!
    
    @survey.should be_billing_error
  end

  it "should send a billing error email upon billing error" do
    pending
  end
  
  it "should transition to stalled if there are not enough responses" do
    @survey.stub!(:full_report?).and_return(false)
    @survey.finish!

    @survey.should be_stalled
  end
  
  it "should send a stalled notification email upon stalling" do
    @survey.stub!(:full_report?).and_return(false)
    Notifier.should_receive(:deliver_survey_stalled_notification)
    @survey.finish!
  end  

  it "should not attempt to bill the sponsor when there are not enough responses" do
    @survey.stub!(:full_report?).and_return(false)
    Gateway.should_not_receive(:bill_survey_sponsor)
    @survey.finish!
  end
end

describe Survey, "that is stalled, with a partial report" do
  before(:each) do
    @survey = Factory(:stalled_survey)
    @invoice = Factory(:invoice, :survey => @survey, :payment_type => 'credit')
    Gateway.stub!(:bill_survey_sponsor).and_return(true)
  end
  
  after(:each) do
    @survey.destroy
  end
  
  it "should be finished if there are enough responses and billing is successful" do
    @survey.stub!(:enough_responses?).and_return(true)
    @survey.finish_with_partial_report!
    
    @survey.should be_finished
  end
  
  it "should transition to billing error if there are enough responses but we couldn't bill the sponsor" do
    @survey.stub!(:enough_responses?).and_return(true)
    Gateway.stub!(:bill_survey_sponsor).and_raise(Exceptions::GatewayException.new("Billing fubar"))
    @survey.finish_with_partial_report!
    
    @survey.should be_billing_error
  end

end

describe Survey, "that is being cancelled (destroyed)" do
  before(:each) do 
    @survey = Factory(:stalled_survey)
    
    Factory(:external_survey_invitation, :survey => @survey)    
    Factory(:survey_invitation, :survey => @survey)
    
    @participation = Factory(:participation, :survey => @survey)
  end
  
  it "should delete all the participations" do
    @survey.destroy
    @survey.participations.should be_empty
  end
  
  it "should send a not-rerunning email" do
    Notifier.should_receive(:deliver_survey_not_rerunning_notification).with(@survey, @participation.participant)
    @survey.destroy
  end

  it "should delete all invitations" do
    @survey.destroy
    @survey.invitations.should be_empty
    @survey.external_invitations.should be_empty
  end
end
