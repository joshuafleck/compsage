module QuestionsHelper
  def print_question(question, options = {})

    # insert the default html attributes to the current_html_parameters hash
    html_parameters = Question::DEFAULT_HTML_ATTRIBUTES[question.question_type].merge(question.html_parameters || {})
    question_parameters = Question::DEFAULT_QUESTION_ATTRIBUTES[question.question_type].merge(question.question_parameters || {})

    text = question.text
    
    # If we're giving this question a number, then prepend it to the question's text.
    text = options[:number].to_s + ". " + text if options.include?(:number)
    responses = options[:responses] || []
    
    # contains the default values based on the previous response(s).
    default_values = []
    
    if question.numerical_response? then
      responses.each { |response|
        default_values << response.numerical_response
      }
    else
      responses.each { |response|
        default_values << response.textual_response
      }
    end
    
    # contains the default qualifications based on the previous response(s).
    default_qualifications = {}
    
    responses.each { |response|
      default_qualifications[response.numerical_response.to_i] = response.qualifications
    } if question.numerical_response?
      
    # construct our html
    return content_tag(:div, :class => question.has_options? ? "options_#{question_parameters[:style]}" : nil) do
      case question.question_type
      when 'text_field', 'numerical_field'    
        html_parameters[:name] ||= "responses[#{question.id}]"
        html_parameters[:type] = "text"
        html_parameters[:value] = default_values.first
        content_tag(:label, text) + " " + tag(:input, html_parameters) + 
          # All non-text questions should allow for user qualifications
          build_qualifications(question,default_qualifications)
      when 'text_area'    
        html_parameters[:name] ||= "responses[#{question.id}]"
        content_tag(:label, text) + content_tag(:textarea, default_values.first, html_parameters)
      when 'radio', 'checkbox'
        html_parameters[:type] = question.question_type
        
        # initialize options incase we have a question that's supposed to have options but doesn't.
        question.options ||= [] 
        
        # start out with our caption
        question_html = content_tag(:p, text)
        
        # then build the options.
        question.options.each_with_index do |option, index|    
          # radio button groups must share the same names, checkbox groups must not share the same names
          html_parameters[:name] = "responses[#{question.id}"+(question.question_type == 'checkbox' ? "_#{index}" : "")+"]"
          html_parameters[:value] = index
          html_parameters[:checked] = (default_values.include?(index) ? 'checked' : nil)
          question_html += content_tag(:label) do
            tag(:input, html_parameters) + option.to_s
          end 
          
          # All non-text questions should allow for user qualifications (note there can be multiple qualifications for checkbox input)
          question_html += build_qualifications(question,default_qualifications,index) + tag(:br) if question.question_type == 'checkbox'
        end
        
        # All non-text questions should allow for user qualifications
        question_html += build_qualifications(question,default_qualifications) if question.question_type == 'radio'
        
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
  
  private
  
  # this method will build the input field for qualifications (numerical responses only)
  def build_qualifications(question,default_qualifications,index = nil)
    question.numerical_response? ? 
      "&nbsp;" +
      # build link to toggle display of qualifications div
      content_tag(:a,
        "Show/Hide Qualifications", 
        {:href => "#", :onclick => "new Effect.toggle('#{question.id}_"+(index.nil? ? "" : "#{index}_")+"qualifications', 'blind', {duration: .5});return false;"}
      ) +
      # div for entering qualifications
      content_tag(:div,
        content_tag(:span,
          " Qualifications: ",
          {:class => "label"}
        ) + 
        tag(:input, 
          {:type => "text", :size => "30", :name => "responses[#{question.id}_"+(index.nil? ? "" : "#{index}_")+"qualifications]", :value => (index.nil? ? default_qualifications.values.first : default_qualifications[index])}
        ), 
        # be sure to display the qualifications div if the qualifications were prepopulated
        {:style => ((index.nil? ? default_qualifications.values.first : default_qualifications[index]).blank? ? "display:none;" : ""), :id => "#{question.id}_"+(index.nil? ? "" : "#{index}_")+"qualifications"}
      ) : "" 
  end
  
end
