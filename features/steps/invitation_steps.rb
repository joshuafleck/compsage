Given /I am on the survey index page/ do
  @survey = Factory.create(:survey, :job_title => "Survey 1") 
  @invitation = Factory.create(:survey_invitation, :survey => @survey, :invitee => @current_organization)
  visits surveys_url 
end
