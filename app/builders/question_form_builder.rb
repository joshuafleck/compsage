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
        @template.content_tag(:div, radio_button(:numerical_response, index) + " " + option)
      }.join("")
    when "textarea"
      label(:textual_response, question.text) + text_area(:textual_response, :rows => 5, :cols => 50)
    when "checkbox"
      p object.inspect
      @template.content_tag(:label, question.text) +
      question.options.to_enum(:each_with_index).collect { |option, index|
        @template.content_tag(:div,
          @template.check_box_tag(
            "#{@object_name}[#{@options[:index]}][numerical_response][]",
            index,
            checked_option?(index),
            :id => "#{@object_name.sub('[', '_').chop}_#{@options[:index]}_numerical_response_#{index}") + " #{option}"
        )
      }.join("")
    end
  end
  
  # Need to override fields_for to change it's behavior when the object is an array.
  # We need it to treat it as fields for the first array element and assign the object to be the
  # array.
  
  def fields_for(record_or_name_or_array, *args, &block)
    p "Building feilds for #{record_or_name_or_array.inspect}"
    case record_or_name_or_array
    when String, Symbol
      name = "#{object_name}[#{record_or_name_or_array}]"
    when Array
      p "Is array.  Setting object to be the array."
      object = record_or_name_or_array
      name = "#{object_name}[#{ActionController::RecordIdentifier.singular_class_name(object.first)}]"
      args.unshift(object)
    else
      object = record_or_name_or_array
      name = "#{object_name}[#{ActionController::RecordIdentifier.singular_class_name(object)}]"
      args.unshift(object)
    end

    @template.fields_for(name, *args, &block)
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
    responses = [*object]
    
    !!responses.find{|r| r.numerical_response == option}
  end
end