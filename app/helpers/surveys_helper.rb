module SurveysHelper

              
  def print_question(question, options = {})

    # insert the default html attributes to the current_html_parameters hash
    html_parameters = Question::DEFAULT_HTML_ATTRIBUTES[question.question_type].merge(question.html_parameters || {});
    question_parameters = Question::DEFAULT_QUESTION_ATTRIBUTES[question.question_type].merge(question.question_parameters || {});
    
    # default name
    html_parameters[:name] ||= "responses[#{question.id}]"

    text = question.text
    # If we're giving this question a number, then prepend it to the question's text.
    text = options[:number].to_s + ". " + text if options.include?(:number)
    
    # pull out the response(s)
    responses = options[:responses] || []
    
    # contains the default values based on the previous response(s).
    default_values = []
    
    
    if question.numerical_response? then
      # question has options, so default_value should use the numerical answer.
      responses.each { |response|
        default_values << response.numerical_response
      }
    else
      # quesiton doesn't have options, is a textual response.
      responses.each { |response|
        default_values << response.textual_response
      }
    end
  
    # construct our html
    return content_tag(:div, :class => question.has_options? ? "options_#{question_parameters[:style]}" : nil) do
      case question.question_type
      when 'text_field', 'numerical_field'
        html_parameters[:type] = "text"
        html_parameters[:value] = default_values.first
        
        content_tag(:label, text) + tag(:input, html_parameters)
      when 'text_area'
        content_tag(:label, text) + content_tag(:text_area, default_values.first, html_parameters)
      when 'radio', 'checkbox'
        html_parameters[:type] = question.question_type
        
        # initialize options incase we have a question that's supposed to have options but doesn't.
        question.options ||= [] 
        
        # start out with our caption
        question_html = content_tag(:p, text)
        
        # then build the options.
        question.options.each_with_index do |option, index|
          html_parameters[:value] = index
          html_parameters[:checked] = 'checked' if default_values.include?(index)
          question_html += content_tag(:label) do
            tag(:input, html_parameters) + option.to_s
          end
        end
        
        # and return it from the block.
        question_html
      when 'text'
        question.markup_text
      else
        # should never get here.
        raise Exception.new("QuestionType not supported")
      end
    
    end
  end
end
