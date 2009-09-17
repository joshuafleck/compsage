Given "I enter an invalid login" do
  fill_in("email", :with => email = @current_organization.email)
  fill_in("password", :with => "garbage!!!!!")
  click_button "Log in"
end

When "I login with invalid invitation credentials" do
  @survey = @current_survey_invitation.survey
  visit survey_login_url(:survey_id => @survey.id, :key => "i iz hackin on ur s1te.")
end