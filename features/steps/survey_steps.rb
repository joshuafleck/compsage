Given /I am logged in/ do
  @current_organization = Factory.create(:organization, :name => "Organization 0")
  visit new_session_url
  fill_in("Email", :with => @current_organization.email)
  fill_in("Password", :with => "test12")
  click_button "Log in"
  response.body.should_not =~ /Password/m
end

Given /there is a predefined question/ do
  @predefined_question = Factory.create(:predefined_question, :name => "Question 1")
end

Given /there is a survey/ do  

  @predefined_question_selected = Factory.create(:predefined_question, :name => "Predefined Question selected")
  @predefined_question_unselected = Factory.create(:predefined_question, :name => "Predefined Question unselected")
 
  @question = Factory.build(
      :question, 
      :text => "Question 1 text", 
      :predefined_question_id => @predefined_question_selected.id
    )
  @custom_question1 = Factory.build(
      :question, 
      :text => "Custom Question 1 text", 
      :question_type => "Numeric response"
    )
  @custom_question2 = Factory.build(
      :question, 
      :text => "Custom Question 2 text", 
      :question_type => "Numeric response"
    ) 
    
  @survey = Factory.create(
    :survey, 
    :job_title => "Survey 1", 
    :questions => [@question,@custom_question1,@custom_question2]) 

end

Given /I have responded to the survey/ do
  @response = Factory.build(:numerical_response, :question => @question, :response => "1.4")
  @participation = Factory.create(
    :participation, 
    :survey => @survey, 
    :responses => [@response], 
    :participant => @current_organization)
end

Given /I am the sponsor/ do
  @survey.sponsor = @current_organization
  @survey.save!
end

Given /I am invited to the survey/ do
  @invitation = Factory.create(:survey_invitation, :survey => @survey, :invitee => @current_organization)
end

Given /I am externally invited to the survey/ do  
  @external_invitation = Factory.create(:external_survey_invitation, :survey => @survey)
end

Given /I am logged in as an external invitee/ do
  visit survey_login_url(:key => @external_invitation.key, :survey_id => @survey.id)   
end
 
Given /I am on the new survey page/ do
  visit new_survey_url
end

Given /I am on the edit survey page/ do
  visit edit_survey_url(@survey)
end

Given /I am on the survey invitations page/ do
  visit survey_invitations_url(@survey)
end

Given /I am on the survey report page/ do
  visit survey_report_url(@survey)
end

Given /I own networks/ do
  @organization1 = Factory.create(:organization, :name => "Organization 1")
  @organization2 = Factory.create(:organization, :name => "Organization 2", :email => "org2@org2.com")
  @organization3 = Factory.create(:organization, :name => "Organization 3", :contact_name => "Organization 3")
  @network1 = Factory.create(:network, :name => "Network 1")
  @network2 = Factory.create(:network, :name => "Network 2")
  @network1.organizations << @organization1
  @network1.organizations << @organization2
  @network2.organizations << @organization3
  @current_organization.owned_networks << @network1
  @current_organization.owned_networks << @network2
end

Given /I am on the survey show page/ do
  if @external_invitation.nil? then
    visit survey_url(@survey)   
  else
    visit survey_login_url(:survey_id => @survey.id, :key => @external_invitation.key)   
  end
end

Given /I am on the survey respond page/ do
  visit survey_questions_url(@survey)
end

Given /I am on the survey index page/ do
  visit surveys_url
end

Given /the survey is stalled/ do
  @survey.end_date = Date.today - 1.day
  @survey.save!
  @survey.finish!
end

Given /the survey is finished/ do
  @survey.end_date = Date.today - 1.day
  @survey.save!
  @survey.finish_with_partial_report!
end

Given /the survey has enough participants but partial report/ do
  #there are 3 questions with numerical responses,
  # if we respond to each question twice, except the last,
  # which we respond to 3 times, then the survey will have
  # adequate participation, but only a partial report
  @survey.questions.each do |question|
    @response = Factory.build(:response, :question => question, :response => "1.4")
    @participation = Factory.create(
      :participation, 
      :survey => @survey, 
      :responses => [@response], 
      :participant => Factory.create(:organization)) 
    @response = Factory.build(:response, :question => question, :response => "1.4")
    @participation = Factory.create(
      :participation, 
      :survey => @survey, 
      :responses => [@response], 
      :participant => Factory.create(:organization))        
  end
  @response = Factory.build(:response, :question => @question, :response => "1.4")
  @participation = Factory.create(
    :participation, 
    :survey => @survey, 
    :responses => [@response], 
    :participant => Factory.create(:organization)) 
end

