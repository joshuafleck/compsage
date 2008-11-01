require 'enumerator'
class QuestionFormBuilder < ActionView::Helpers::FormBuilder
  
  # builds  a form field for a survey question.
  def form_field
    case question.question_type
    when "text_field"
      label(:textual_response, question.text) + text_field(:textual_response, :size => 40) + error_text
    when "numerical_field"
      label(:numerical_response, question.text) + text_field(:numerical_response, :size => 5) + error_text
    when "radio"
      @template.content_tag(:label, question.text) +
      question.options.to_enum(:each_with_index).collect { |option, index|
        @template.content_tag(:div, radio_button(:numerical_response, index.to_f) + " " + option)
      }.join("")
    when "text_area"
      label(:textual_response, question.text) + text_area(:textual_response, :rows => 5, :cols => 50)
    when "checkbox"
      @template.content_tag(:label, question.text) +
      question.options.to_enum(:each_with_index).collect { |option, index|
        @template.content_tag(:div,
          @template.check_box_tag(
            "#{@object_name}[#{@options[:index]}][textual_response][]",
            index,
            checked_option?(index),
            :id => "#{@object_name.sub('[', '_').chop}_#{@options[:index]}_textual_response_#{index}") + " #{option}"
        )
      }.join("")
    end
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
  
  # checks for whether the response(s) include one where the specified option was checked.
  def checked_option?(option)
    object.textual_response.include?(option.to_s) unless object.textual_response.nil?
  end
end
