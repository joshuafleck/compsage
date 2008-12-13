Given /I am logged in/ do
  @current_organization = Factory.create(:organization)
  visits new_session_url
  fills_in("Email", :with => @current_organization.email)
  fills_in("Password", :with => "test12")
  clicks_button "Log in"
  response.body.should_not =~ /Password/m
end

Given /I am invited to the survey/ do
  @current_organization = Factory.create(:organization)
  visits new_session_url
  fills_in("Email", :with => @current_organization.email)
  fills_in("Password", :with => "test12")
  clicks_button "Log in"
  clicks_link("Log Out")
  @survey = Factory.create(:survey, :sponsor => @current_organization) 
  @invitation = Factory.create(:external_survey_invitation, :survey => @survey)
  visits survey_login_url(:key => @invitation.key, :survey_id => @survey.id)   
end
 
Given /I am on the new survey page/ do
  @predefined_question = Factory.create(:predefined_question, :name => "Question 1")
  visits new_survey_url
end

Given /I am on the edit survey page/ do
  @survey = Factory.create(:survey, :sponsor => @current_organization)
  @predefined_question_selected = Factory.create(:predefined_question, :name => "Predefined Question selected")
  @predefined_question_unselected = Factory.create(:predefined_question, :name => "Predefined Question unselected")
  @question = Factory.create(
      :question, 
      :survey => @survey, 
      :text => "Question 1 text", 
      :predefined_question_id => @predefined_question_selected.object_id
    )
  @custom_question1 = Factory.create(
      :question, 
      :survey => @survey, 
      :text => "Custom Question 1 text", 
      :custom_question_type => "Numeric response"
    )
  @custom_question2 = Factory.create(
      :question, 
      :survey => @survey, 
      :text => "Custom Question 2 text", 
      :custom_question_type => "Numeric response"
    )
  visits edit_survey_url(@survey)
end

Given /I am on the survey invitations page/ do
  @survey = Factory.create(:survey, :sponsor => @current_organization)
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
  visits survey_invitations_url(@survey)
end

Given /I am on the survey show page/ do
  @survey = Factory.create(:survey, :sponsor => @current_organization) 
  visits survey_url(@survey)   
end

Given /I am on the survey respond page/ do
  @survey = Factory.create(:survey, :job_title => "Survey 1") 
  @question = Factory.create(:question, :survey => @survey, :text => 'Question 1')
  @invitation = Factory.create(:survey_invitation, :survey => @survey, :invitee => @current_organization)
  visits survey_questions_url(:survey_id => @survey.id)
end

Given /I am on the survey stalled page/ do
  @survey = Factory.create(:survey, :sponsor => @current_organization) 
  @question = Factory.create(:question, :survey => @survey, :text => 'Question 1')
  @external_survey_invitation = Factory.create(:external_survey_invitation, :survey => @survey);
  @participation = Factory.create(:participation, :participant => @external_survey_invitation)
  @response = Factory.create(:response,:question => @question,:participation => @participation);
  @survey.end_date = Date.today - 1.day
  @survey.save!
  @survey.finish!
  visits survey_url(@survey)   
end


