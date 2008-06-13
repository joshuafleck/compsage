DEFAULT_HTML_ATTRIBUTES =  {  'text_field' => {:size => 30},
                            'numerical_field' => {:size => 6}, 
                            'text_area' => { :rows => 3,
                                            :cols => 40},
                            'radio' => {},
                            'check' => {},
                            'text' => {}}
DEFAULT_QUESTION_ATTRIBUTES = { 'text_field' => {:style => 'veritcal'},
                              'numerical_field' => {:style => 'veritcal'}, 
                              'text_area' => {:style => 'vertical'},
                              'radio' => {:style => 'veritcal'},
                              'check' => {:style => 'veritcal'},
                              'text' => {:style => 'veritcal'}}

module SurveysHelper
  def print_question(question, options = {})

    # insert the default html attributes to the current_html_parameters hash
    html_parameters = DEFAULT_HTML_ATTRIBUTES[question_type].merge(question.html_parameters || {});
    question_parameters = DEFAULT_QUESTION_ATTRIBUTES[question_type].merge(question.question_parameters || {});
    
    # default name
    current_html_parameters[:name] ||= "responses[#{question.id}]"

    # If we're giving this question a number, then prepend it to the question's text.
    if options.include?(:number) then
      text = option[:number].to_s + ". " + question.text
    end
    
    # pull out the response(s)
    responses = options[:responses] || []
    
    # contains the default values based on the previous response(s).
    default_value = []
    
    
    if question.numerical_response? then
      # question has options, so default_value should use the numerical answer.
      responses.each { |response|
        default_value << response.numerical_answer
      }
    else
      # quesiton doesn't have options, is a textual response.
      responses.each { |response|
        default_value << response.textual_answer
      }
    end
    
    question_string = content_tag(:div, :class => "options_#{question_parameters[:style]}") do
      case question.question_type
      when 'text_field', 'numerical_field'
        question_string +=  '<label>' + text + '</label> <input type="text"' +
                            convert_hash_to_html_attributes(current_html_parameters) + 
                            'value="' + default_value[0].to_s + '"' +
                            ' />'
      when 'text_area'
        question_string +=  '<label>' + text + '</label> <textarea ' +
                            convert_hash_to_html_attributes(current_html_parameters) + 
                            '>' + default_value[0].to_s + '</textarea>'
      when 'radio'
        question_string += text + "<br />"
        if !options.nil? then
          puts options.inspect
          options.each_index { |i|
            question_string +=  '<label><input type="radio"' + 
                                convert_hash_to_html_attributes(current_html_parameters) + 
                                ' value="' + i.to_s + '"' + 
                                (default_value.include?(i) ? " checked=\"checked\"" : "") + 
                                ' /> ' + options[i].to_s + '</label>'
          }
        end
      when 'check'
        question_string += text + "<br />"
        base_name = current_html_parameters[:name]
        if !options.nil? then
          options.each_index { |i|
            current_html_parameters[:name] = base_name + "[#{i}]";
            question_string +=  '<label><input type="checkbox"' + 
                                convert_hash_to_html_attributes(current_html_parameters) + 
                                ' value="' + i.to_s + '"' + 
                                (default_value.include?(i) ? " checked=\"checked\"" : "") + 
                                ' /> ' + options[i] + '</label>'
          }
        end
      when 'text'
        question_string += markup_text
      else
        # should never get here.
        return "None :(  *tear*"
      end
    
    end
    
    return question_string
  end
  
  private
  
  def convert_hash_to_html_attributes(params)
    attribute_string = ""
    return '' if params.nil?
    params.each {|key, value|
      attribute_string += ' ' + key.to_s + '="' + value.to_s + '"'
    }
    return attribute_string
  end
end
