Given /I am logged in/ do
  @current_organization = Factory.create(:organization)
  visits new_session_url
  fills_in("Email", :with => @current_organization.email)
  fills_in("Password", :with => "test12")
  clicks_button "Log in"
  response.body.should_not =~ /Password/m
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

