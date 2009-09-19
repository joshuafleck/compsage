Given "I am on the survey response page" do
  visit survey_questions_url(@survey)
end

Given /^I am sponsoring a running survey with a (.*) question/ do |type|
  @question = Factory.build((type.gsub(" ", "_") + "_question").intern)
  @survey = Factory(:survey,
                    :aasm_state => 'running',
                    :sponsor => @current_organization,
                    :questions => [
                      @question
                    ])
end

Given "I am sponsoring a survey with every question type" do
  @questions = ['percent', 'multiple_choice', 'numerical', 'text', 'wage', 'base_wage'].collect do |type|
    Factory.build("#{type}_question".intern)
  end

  @survey = Factory(:survey,
                    :aasm_state => 'running',
                    :sponsor => @current_organization,
                    :questions => @questions)
end

Given /^the survey to which I am invited is "([^\"]*)"$/ do |state|
  @current_survey_invitation.survey.aasm_state = state
  @current_survey_invitation.survey.save!
end

Given "the survey has a partial response" do
  5.times do
    Factory(:participation, :survey => @survey)
  end
  question = Factory(:text_question, :survey => @survey)
  response = Factory.build(:response, :question => question)
  Factory(:invoice, :survey => @survey)
  participation = Factory(:participation, :survey => @survey, :responses => [response])
end

And "the survey has been invoiced" do
  Factory.create(:invoice, :survey => @survey)
end

And "I am invoicing the survey" do
  Factory.create(:invoice, :survey => @survey, :payment_type => 'invoice')
end

When /^I enter "([^"]*)"$/ do |text|
  name = "participation[response][#{@question.id}][response]"
  fill_in name, :with => "", :method => :set
  fill_in name, :with => text, :method => :set
end

Then /^it should read "([^"]*)"$/ do |text|
  field_named("participation[response][#{@question.id}][response]").value.should == text
end

When /^I choose the (hourly|annual) pay type$/ do |type|
  type = type == "annual" ? "Annually" : "Hourly"
  select type, :from => "participation[response][#{@question.id}][unit]"
end

When "I am on the survey show page" do
  visit survey_url(@survey)
end

When "I am on the edit survey page" do
  visit edit_survey_url(@survey)
end

When "I create the survey" do
  fill_in "Job title", :with => "survey 1"
  fill_in "Job description", :with => "text"
  field_with_id('form_submit', 'submit').click
end

When "I edit the survey" do
  fill_in "Job description", :with => "text"
  select("4", :from => "survey_days_to_extend") 
  field_with_id('form_submit', 'submit').click
end

When "I unsuccessfully edit the survey" do
  fill_in "Job title", :with => ""
  fill_in "Job description", :with => "text"
  select("4", :from => "survey_days_to_extend") 
  field_with_id('form_submit', 'submit').click
end

When "I answer the entire survey" do
  @questions ||= [@question] # Handle if we've just made a single question.

  @questions.each do |question|
    answer = nil
    units  = nil
    input_field_name = "participation[response][#{question.id}][response]"
    units_field_name = "participation[response][#{question.id}][unit]"

    if question.response_class <= NumericalResponse then # fill in numeric value
      fill_in input_field_name, :with => "10"
      if question.response_class <= WageResponse then    # select units
        select "Hourly", :from => units_field_name
      end
    elsif question.response_class <= TextualResponse then # fill in text value
      fill_in input_field_name, :with => "text"
    else # select option
      choose "participation_response_#{question.id}_response_0"
    end
  end
  
  click_button "Submit My Responses"
end

When "I cancel the survey response" do
  click_link "Cancel"
end

Then "I should be on the survey show page" do
  response_body.should =~ /Manage Your Survey/
end

Then "I should see the response success message" do
  # response_body.should =~ /Thank you for participating in the survey/
  div("flash_notice").text.should_not be_blank
end

Then "I should see a response warning" do
  div("warning_#{@question.id}").text.should_not be_blank
end

Then "I should not see a response warning" do
  div("warning_#{@question.id}").text.should be_blank
end

When "I am on the survey report page" do
  visit survey_report_url(@survey)
end
