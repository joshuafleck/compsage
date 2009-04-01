require 'enumerator'
class QuestionFormBuilder < ActionView::Helpers::FormBuilder
  
  def initialize(object_name, object, template, options, proc)
    super
    if @object.class < Response
      @object_name.sub!(@object_name.match(/\[([\w\_]*\_)response/)[1], '')
    end
  end

  # builds a form field for a survey question.
  def form_field
    response_class = question.response_class
    case response_class.field_type
    when "text_box"
      label(:response, question.text) + text_field(:response, response_class.field_options.merge(:value => object.formatted_response)) + unit_field + error_text
    when "radio"
      @template.content_tag(:div, question.text, :class => "label") +
      question.options.to_enum(:each_with_index).collect { |option, index|
        @template.content_tag(:label, radio_button(:response, index.to_f) + " " + option, :class => 'option')
      }.join("")
    when "text_area"
      label(:response, question.text) + text_area(:response, :rows => 5, :cols => 50)
    when "checkbox"
      @template.content_tag(:label, question.text) +
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
 
  # displays the units select box if the response type has any units defined
  def unit_field
    if units = question.response_class.units then
      ' ' + select(:unit, units.form_values, :prompt => "Select #{units.name}") 
    else
      ''
    end
  end
  # checks for whether the response(s) include one where the specified option was checked.
  def checked_option?(option)
    object.response.include?(option.to_s) unless object.response.nil?
  end
end
