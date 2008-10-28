require 'enumerator'
class QuestionFormBuilder < ActionView::Helpers::FormBuilder
  def form_field
    case question.question_type
    when "text_field"
      label(:textual_response, question.text) + text_field(:textual_response, :size => 40) + error_text
    when "numerical_field"
      label(:numerical_response, question.text) + text_field(:numerical_response, :size => 5) + error_text
    when "radio"
      @template.content_tag(:label, question.text) +
      question.options.to_enum(:each_with_index).collect { |option, index|
        @template.content_tag(:div, radio_button(:numerical_response, index) + " " + option)
      }.join("")
    end +
    " Qualifications: " + text_field(:qualifications)
  end
  
  private
  
  # return the question for the response object.
  def question
    if object.is_a?(Array)
      object.first.question
    else
      object.question
    end
  end
  
  # pull out the errors to display if any exist
  def error_text
    if object.errors.count > 0 then
      @template.content_tag(:div, object.errors.full_messages.join(" &amp; "), :class => 'error_description')
    else
      ""
    end
  end
end