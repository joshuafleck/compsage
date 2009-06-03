require 'enumerator'
class QuestionFormBuilder < ActionView::Helpers::FormBuilder
  
  def initialize(object_name, object, template, options, proc)
    super
    if @object.class < Response
      puts object_name
      puts @object.inspect
      @object_name.sub!(@object_name.match(/\[([\w\_]*\_)response/)[1], '')
    end
  end

  # builds a form field for a survey question.
  def form_field
    response_class = question.response_class
    case response_class.field_type
    when "text_box"
      label(:response, question_text) +
      text_field(:response, response_class.field_options.merge(:class => question.response_type, :value => object.formatted_response)) +
      unit_field + error_text + warning_field(question.id)
    when "radio"
      @template.content_tag(:div, question_text, :class => "label") +
      question.options.to_enum(:each_with_index).collect { |option, index|
        @template.content_tag(:label, radio_button(:response, index.to_f) + " " + option, :class => 'option')
      }.join("") + 
      error_text # error should be displayed in the case that a qualification was entered, but no response
    when "text_area"
      label(:response, question_text) + text_area(:response, :rows => 5, :cols => 50)
    when "checkbox"
      @template.content_tag(:label, question_text) +
      question.options.to_enum(:each_with_index).collect { |option, index|
        @template.content_tag(:div,
          @template.check_box_tag(
            "#{@object_name}[#{@options[:index]}][response][]",
            index,
            checked_option?(index),
            :id => "#{@object_name.sub('[', '_').chop}_#{@options[:index]}_response_#{index}") + " #{option}"
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
      @template.content_tag(:div, object.errors.full_messages.uniq.join(" &amp; "), :class => 'error_description')
    else
      ""
    end
  end
  
  # this will denote the required questions
  def question_text
    if question.required? then
      question.text + "&nbsp;" + @template.image_tag("required.gif")
    else
      question.text
    end
  end
 
  # displays the units select box if the response type has any units defined
  def unit_field
    if units = question.response_class.units then
      ' ' + select(:unit, units.form_values, {:prompt => "Select #{units.name}"}, {:class => "units #{units.name}"}) 
    else
      ''
    end
  end
  
  # Location where any range check warnings will be displayed
  def warning_field(question_id)
    @template.content_tag(:div, "", :class => 'error_description', :id => "warning_#{question_id}")
  end
  
  # checks for whether the response(s) include one where the specified option was checked.
  def checked_option?(option)
    object.response.include?(option.to_s) unless object.response.nil?
  end
end
