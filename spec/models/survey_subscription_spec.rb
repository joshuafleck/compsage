require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def valid_survey_subscription_attributes
  {
    :survey => Survey.new,
    :organization => Organization.new,
    :relationship => 'sponsor'
  }
end

describe SurveySubscription do
  before(:each) do
    @survey_subscription = SurveySubscription.new
  end

  it "should be valid" do
    @survey_subscription.attributes = valid_survey_subscription_attributes
    @survey_subscription.should be_valid
  end
  
  it "should belong to a survey" do
    SurveySubscription.reflect_on_association(:survey).should_not be_nil
  end
  
  it "should belong to an organization" do
    SurveySubscription.reflect_on_association(:organization).should_not be_nil
  end
  
  it "should be invalid without a survey" do
    @survey_subscription.attributes = valid_survey_subscription_attributes.except(:survey)
  end
  
  it "should be invalid without an organization" do
    @survey_subscription.attributes = valid_survey_subscription_attributes.except(:organization)
  end
  
  it "should be invalid without a relationship" do
    @survey_subscription.attributes = valid_survey_subscription_attributes.except(:relationship)
  end
end
