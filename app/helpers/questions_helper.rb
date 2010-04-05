module QuestionsHelper
  # This method determines which path to
  def determine_billing_url(survey)
    if !current_association then
      return new_survey_billing_path(@survey)
    else
      return instructions_survey_billing_path(@survey)
    end
  end
end
