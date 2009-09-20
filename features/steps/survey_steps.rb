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

Given "I am sponsoring a survey with a follow-up to a (.*) question" do |type|
  case type
  when "yes/no"
    @base_question = Factory.build(:multiple_choice_question, :options => ["Yes", "No"])
  when "multiple choice"
    @base_question = Factory.build(:multiple_choice_question, :options => ["Yes", "No", "Maybe"])
  when "text"
    @base_question = Factory.build(:text_question, :options => ["Yes", "No"])
  end

  @follow_up_question = Factory.build(:text_question, :parent_question => @base_question)

  @survey = Factory(:survey,
                    :aasm_state => 'running',
                    :sponsor => @current_organization,
                    :questions => [@base_question, @follow_up_question])
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

Given "the survey has been invoiced" do
  Factory.create(:invoice, :survey => @survey)
end

Given "I am invoicing the survey" do
  Factory.create(:invoice, :survey => @survey, :payment_type => 'invoice')
end

Given "I have previously responded to the survey" do
  participation = Factory(:participation, :survey => @survey, :participant => @current_organization)

  @survey.questions.each do |question|
    response = participation.responses.build(:question => question, :type => question.response_type)
    if question.response_class <= NumericalResponse then
      response.response = "10"
      if question.response_class <= WageResponse then
        response.unit = "Hourly"
      end
    elsif question.response_class <= TextualResponse then
      response.response = "text"
    elsif question.response_class <= MultipleChoiceResponse then
      response.response = 0
    end

    response.save
  end
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
  fill_in "survey_job_title", :with => "survey 1"
  fill_in "survey_description", :with => "text"
  click_button 'form_submit'
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

When "I answer the entire survey( with comments)?" do |with_comments|
  with_comments = !with_comments.blank?

  if @questions.nil? then
    if @question.nil? then
      @questions = @survey.questions
    else
      @questions = [@question]
    end
  end

  @questions.each do |question|
    answer = nil
    units  = nil
    input_field_name   = "participation[response][#{question.id}][response]"
    units_field_name   = "participation[response][#{question.id}][unit]"
    comment_field_name = "participation[response][#{question.id}][comments]"

    if question.response_class <= NumericalResponse then # fill in numeric value
      fill_in input_field_name, :with => "10"
      if question.response_class <= WageResponse then    # select units
        select "Hourly", :from => units_field_name
      end
      fill_in comment_field_name, :with => "comments" if with_comments
    elsif question.response_class <= TextualResponse then # fill in text value
      fill_in input_field_name, :with => "text"
    else # select option
      choose "participation_response_#{question.id}_response_0"
      fill_in comment_field_name, :with => "comments" if with_comments
    end
  end
  
  click_button "Submit My Responses"
end

When "I respond to the parent question" do
  if @base_question.response_class == MultipleChoiceResponse
    choose "participation_response_#{@base_question.id}_response_0"
  elsif @base_question.response_class == TextualResponse
    fill_in "participation[response][#{@base_question.id}][response]", :with => "Hi", :method => :set
  end
end

When "I change my response to the parent question" do
  if @base_question.response_class == MultipleChoiceResponse
    choose "participation_response_#{@base_question.id}_response_1"
  elsif @base_question.response_class == TextualResponse
    fill_in "participation[response][#{@base_question.id}][response]", :with => "Bye", :method => :set
  end
end

When "I remove my response to the parent question" do
  fill_in "participation[response][#{@base_question.id}][response]", :with => "", :method => :set
  field_named("participation[response][#{@base_question.id}][response]").fire_event("onkeyup")
end

When "I cancel the survey response" do
  click_link "Cancel"
end

When "I respond to just the follow-up question" do
  fill_in "participation[response][#{@follow_up_question.id}][response]", :with => "HI!!!", :method => :set
  click_button "Submit My Responses"
end

Then "I should be on the survey show page" do
  response_body.should =~ /Manage Your Survey/
end

Then "I should see the response success message" do
  div("flash_notice").text.should_not be_blank
end

Then "I should see a response warning" do
  div("warning_#{@question.id}").text.should_not be_blank
end

Then "I should not see a response warning" do
  div("warning_#{@question.id}").text.should be_blank
end

Then "I should see my previous responses" do
  @questions.each do |question|
    input_field_name = "participation[response][#{question.id}][response]"
    units_field_name = "participation[response][#{question.id}][unit]"

    if question.response_class == NumericalResponse then
      field_named(input_field_name).value.should == "10.0"
    elsif question.response_class == PercentResponse then
      field_named(input_field_name).value.should == "10.0%"
    elsif question.response_class <= WageResponse then
      field_named(input_field_name).value.should == "$10.00"
      field_named(units_field_name).value.should == ["Hourly"] 
    elsif question.response_class <= TextualResponse then
      field_named(input_field_name).value.should == "text"
    elsif question.response_class <= MultipleChoiceResponse then
      field_labeled("Option 1").should be_checked
    end

  end
end

Then "I should see my comments" do
  @questions.each do |question|
    if question.response_class.accepts_comment? then
      field_named("participation[response][#{question.id}][comments]").value.should_not be_blank
    end
  end
end

When "I am on the survey report page" do
  visit survey_report_url(@survey)
end

When "I search for a running survey by name" do
  @name = "Searchable survey"
  @survey = Factory(:running_survey,:job_title => @name)
  visit surveys_url
  fills_in 'search_text', :with => @name
  field_with_id('submit', 'submit').click
end

Then "I should see the survey I searched for" do
  response.body.should =~ /#{@name}/m
end

Given "I am on the survey reports index" do
  visit reports_surveys_url
end

Given "I am on the surveys index" do
  visit surveys_url
end

Given "I have been invited, sponsored, participated, and finished surveys" do
  @invited_survey = Factory(:sent_survey_invitation, :invitee => @current_organization).survey
  @sponsored_survey = Factory(:running_survey, :sponsor => @current_organization)
  @survey = Factory(:running_survey)
  @participated_survey = Factory(:participation, :participant => @current_organization).survey
  @finished_survey = Factory(:finished_survey, :sponsor => @current_organization)
end

Then "I should see invited, sponsored, participated, and finished surveys" do
  response.body.should =~ /#{@invited_survey.job_title}/m
  response.body.should =~ /#{@sponsored_survey.job_title}/m
  response.body.should =~ /#{@survey.job_title}/m
  response.body.should =~ /#{@participated_survey.job_title}/m
  response.body.should =~ /#{@finished_survey.job_title}/m
end

When "I cancel the survey" do
  @browser.startClicker("OK")
  click_link "Cancel"
end

Then "I should be on the survey index" do
  response_body.should =~ /Browse Current Surveys/m
end

Given "I am on the new survey page" do
  visit new_survey_url
end

Then "I should be on the survey invitations page" do
  response_body.should =~ /Invitations to/m
end

Given "the survey has enough invitations" do
  5.times do
    Factory(:pending_survey_invitation,:survey => @survey)
  end  
end

Then "I should be on the survey preview page" do
  response_body.should =~ /Preview/m
end

Given "I am on the survey preview page" do
  visit preview_survey_questions_url(@survey)
end

Given "I am on the survey billing page" do
  visit new_survey_billing_url(@survey)
end

When "I preview the survey" do
  response_body.should =~ /Question/m
end

When "I click next" do
  click_button 'next'
end

When "I click back" do
  click_button 'previous'
end

Then "I should be on the survey billing page" do
  response_body.should =~ /Billing/m
end

Then "I should be on the new survey page" do
  response_body.should =~ /Job title/m
end

Then "the follow-up question should be disabled" do
  field_named("participation[response][#{@follow_up_question.id}][response]").should be_disabled
end

Then "the follow-up question should not be disabled" do
  field_named("participation[response][#{@follow_up_question.id}][response]").should_not be_disabled
end

When "I pay via credit card" do
  fill_in 'invoice_organization_name', :with => 'test org name'
  fill_in 'invoice_contact_name', :with => 'test contact name'
  fill_in 'invoice_address_line_1', :with => 'test addr 1'
  fill_in 'invoice_address_line_2', :with => 'test addr 2'
  fill_in 'invoice_city', :with => 'test city name'
  fill_in 'invoice_zip_code', :with => '12345'
  fill_in 'invoice_phone', :with => '(952) 393-1749'
  select 'MN', :from => 'invoice_state'
  choose "invoice_payment_type_credit"
  fill_in 'active_merchant_billing_credit_card_first_name', :with => 'test first name'
  fill_in 'active_merchant_billing_credit_card_last_name', :with => 'test last name'
  fill_in 'active_merchant_billing_credit_card_number', :with => '4111111111111111'
  fill_in 'active_merchant_billing_credit_card_verification_value', :with => '123'
  select 'visa', :from => 'active_merchant_billing_credit_card_type'
  select '5', :from => 'active_merchant_billing_credit_card_month'
  select '2019', :from => 'active_merchant_billing_credit_card_year'
  click_button 'next'
end

When "I unsuccessfully pay via credit card" do
  fill_in 'invoice_organization_name', :with => 'test org name'
  fill_in 'invoice_contact_name', :with => 'test contact name'
  fill_in 'invoice_address_line_1', :with => 'test addr 1'
  fill_in 'invoice_address_line_2', :with => 'test addr 2'
  fill_in 'invoice_city', :with => 'test city name'
  fill_in 'invoice_zip_code', :with => '12345'
  fill_in 'invoice_phone', :with => '(952) 393-1749'
  select 'MN', :from => 'invoice_state'
  choose "invoice_payment_type_credit"
  fill_in 'active_merchant_billing_credit_card_first_name', :with => 'test first name'
  fill_in 'active_merchant_billing_credit_card_last_name', :with => 'test last name'
  fill_in 'active_merchant_billing_credit_card_number', :with => '411dzvfvzdfv1111'
  fill_in 'active_merchant_billing_credit_card_verification_value', :with => '123'
  select 'visa', :from => 'active_merchant_billing_credit_card_type'
  select '5', :from => 'active_merchant_billing_credit_card_month'
  select '2019', :from => 'active_merchant_billing_credit_card_year'
  click_button 'next'
end

When "I pay via invoice" do
  fill_in 'invoice_organization_name', :with => 'test org name'
  fill_in 'invoice_contact_name', :with => 'test contact name'
  fill_in 'invoice_address_line_1', :with => 'test addr 1'
  fill_in 'invoice_address_line_2', :with => 'test addr 2'
  fill_in 'invoice_city', :with => 'test city name'
  fill_in 'invoice_zip_code', :with => '12345'
  fill_in 'invoice_phone', :with => '(952) 393-1749'
  select 'MN', :from => 'invoice_state'
  choose "invoice_payment_type_invoice"
  click_button 'next'
end

When "I unsuccessfully pay via invoice" do
  fill_in 'invoice_organization_name', :with => 'test org name'
  fill_in 'invoice_contact_name', :with => 'test contact name'
  fill_in 'invoice_address_line_1', :with => 'test addr 1'
  fill_in 'invoice_address_line_2', :with => 'test addr 2'
  fill_in 'invoice_city', :with => 'test city name'
  fill_in 'invoice_zip_code', :with => '12345'
  fill_in 'invoice_phone', :with => '(952)6 393-1749'
  select 'MN', :from => 'invoice_state'
  choose "invoice_payment_type_invoice"
  click_button 'next'
end

