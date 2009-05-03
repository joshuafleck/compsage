question.send(@responses_method).each do |response|    
  p_pdf.text "#{response.textual_response}"
end
