Given "I am on the survey response page" do
  visit add_subdomain(survey_questions_url(@survey))
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
                    :sponsor => @current_organization)

  @survey.questions.destroy_all # Remove standard questions.
  @survey.questions += @questions
  @survey.save
end

Given /^I am sponsoring a survey with a follow\-up to a (.*) question$/ do |type|
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
  Factory(:invoice, :survey => @survey)
  response = Factory.build(:response, :question => question)
  participation = Factory(:participation, :survey => @survey, :responses => [response])
end

Given "the survey has been invoiced" do
  Factory.create(:invoice, :survey => @survey)
end

Given "I am invoicing the survey" do
  Factory.create(:invoice, :survey => @survey, :payment_type => 'invoice')
end

Given "I have previously responded to the survey" do
  participation = Factory.build(:participation, :survey => @survey, :participant => @current_organization, :responses => [])

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

  end
  
  participation.save
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
  visit add_subdomain(survey_url(@survey))
end

When "I am on the edit survey page" do
  visit add_subdomain(edit_survey_url(@survey))
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

When /^I answer the entire survey( with comments)?$/ do |with_comments|
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

When "I check the required button" do
  check "question_required"
end

When "I add a predefined question" do
  select "6", :from => 'predefined_questions'

  click_button "Add Question"
end

When "I add a custom question" do
  select "0", :from => 'predefined_questions'
  fill_in 'custom_question_text', :with => "Is this position exempt"
  select "Yes/No", :from => 'custom_question_response'

  click_button "Add Question"
end

When "I attempt to add an invalid custom question" do
  select "0", :from => 'predefined_questions'

  click_button "Add Question"
end

When "I move the first question down" do
  @moved_question_text      = get_element_by_xpath("id('new_questions')/li[1]//div[@class='question_display_text']").text
  @moved_question_position  = 2 # The new position of the question to verify later.
  link = get_element_by_xpath("id('new_questions')/li[1]//a[@class='question_down']")
  link.click
end

When "I move the second question up" do
  @moved_question_text      = get_element_by_xpath("id('new_questions')/li[2]//div[@class='question_display_text']").text
  @moved_question_position  = 1 # The new position of the question to verify later.
  link = get_element_by_xpath("id('new_questions')/li[2]//a[@class='question_up']")
  link.click
end

When "I edit the first question" do
  get_element_by_xpath("id('new_questions')/li[1]//a[@class='question_edit']").click
  get_element_by_xpath("id('new_questions')/li[1]//input[@type='text'][@class='question_text']").value = "Edited question"

  click_button "Save"
end

When "I incorrectly edit the first question" do
  get_element_by_xpath("id('new_questions')/li[1]//a[@class='question_edit']").click
  get_element_by_xpath("id('new_questions')/li[1]//input[@type='text'][@class='question_text']").value = ""

  click_button "Save"
end

When "I delete the first question" do
  @deleted_question_text = get_element_by_xpath("id('new_questions')/li[1]//div[@class='question_display_text']").text
  get_element_by_xpath("id('new_questions')/li[1]//a[@class='question_delete']").click
end

When "I respond to the invited survey" do
  within "div#invitations" do
    click_link @invited_survey.job_title
  end
  click_link "Respond to this survey"
  fill_in "participation[response][#{@invited_survey.questions.first.id}][response]", :with => "100"
  click_button "Submit My Responses"
end

When "I decline the survey invitation" do
  click_link "Decline Invitation"
end

Then "I should not see the survey invitation" do
  get_element_by_xpath("id('invitations')").should be_nil
end

Then "I should not see the deleted question" do
  wait_for_javascript
  response_body.should_not include(@deleted_question_text)
end

Then "I should see the edited question" do
  wait_for_javascript
  get_element_by_xpath("id('new_questions')/li[1]//div[@class='question_display_text']").text.should == "Edited question"
end

Then "the question should be moved" do
  wait_for_javascript
  text = get_element_by_xpath("id('new_questions')/li[#{@moved_question_position}]//div[@class='question_display_text']").text
  text.should == @moved_question_text
end

Then "I should see the new question" do
  wait_for_javascript
  # Assumed the question added is FLSA status
  response_body.should =~ /Is this position exempt/
end

Then "I should see required" do
  wait_for_javascript
  # Assumed the question added is FLSA status
  response_body.should =~ /Required/
end

Then "I should not see the new question" do
  wait_for_javascript

  response_body.should_not =~ /Is this position exempt/
end

Then "I should see an invalid question error" do
  wait_for_javascript

  response_body.should =~ /Question text is required/
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
  visit add_subdomain(survey_report_url(@survey))
end

When "I search for a running survey by name" do
  @name = "Searchable survey"
  @survey = Factory(:running_survey,:job_title => @name)
  visit add_subdomain(surveys_url)
  fills_in 'search_text', :with => @name
  field_with_id('submit', 'submit').click
end

Then "I should see the survey I searched for" do
  response.body.should =~ /#{@name}/m
end

Given "I am on the survey reports index" do
  visit add_subdomain(reports_surveys_url)
end

Given "I am on the surveys index" do
  visit add_subdomain(surveys_url)
end

Given "I have been invited, sponsored, participated, and finished surveys" do
  @invited_survey = Factory(:sent_survey_invitation, :invitee => @current_organization).survey
  @sponsored_survey = Factory(:running_survey, :sponsor => @current_organization)
  @survey = Factory(:running_survey)
  
  @participated_survey =  Factory(:running_survey, :sponsor => Factory(:organization))
  participation = Factory.build(:participation, 
    :participant => @current_organization, 
    :survey => @participated_survey, 
    :responses => [])
  @participated_survey.questions.each do |question|  
    participation.responses << Factory.build(:numerical_response, :question => question, :response => 1)
  end  
  participation.save 
    
  @finished_survey = Factory(:finished_survey, :sponsor => @current_organization)
end

Given "I have a survey invitation" do
  @invited_survey = Factory(:running_survey)
  @invited_survey.questions[1..-1].each(&:destroy) # Remove the standard questions.
  @invitation     = Factory(:sent_survey_invitation,
                            :survey => @invited_survey,
                            :invitee => @current_organization)
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
  visit add_subdomain(new_survey_url)
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
  visit add_subdomain(preview_survey_questions_url(@survey))
end

Given "I am on the survey billing page" do
  visit add_subdomain(new_survey_billing_url(@survey))
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

