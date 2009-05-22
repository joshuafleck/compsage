module SurveysHelper

  INDEX_PLACEHOLDER = 'replace_with_timestamp'
  TEXT_PLACEHOLDER = 'replace_with_text'
  RESPONSE_TYPE_PLACEHOLDER = 'replace_with_response_type'
  
  # save the questions related to each predefined question as a json array
  def predefined_question_html(form)  
    pdqs = {}
    PredefinedQuestion.all.each do |pdq|
      questions = []
      pdq.build_questions.each do |question|
        questions << render(:partial => "question", :locals => { :form => form, :index => INDEX_PLACEHOLDER }, :object => question )
      end
      pdqs[pdq.id.to_s] = questions
    end
    pdqs.to_json
  end
  
  # save a blank question form as a json object
  def custom_question_html(form) 
    question = Question.new(:custom_question_type => RESPONSE_TYPE_PLACEHOLDER, :text => TEXT_PLACEHOLDER)
    render(:partial => "question", :locals => { :form => form, :index => INDEX_PLACEHOLDER }, :object =>  question).to_json
  end

end
