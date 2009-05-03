dataset = []
total_response_count = (question.send(@responses_method).count).to_f
question_response_count = 0.0
question.options.each_with_index do |option, index|

  question_response_count = question.send(@grouped_responses_method)[index.to_f].nil? ? 0 : question.send(@grouped_responses_method)[index.to_f].size
  
  dataset[index] = 
    [
      "#{option}",
      "#{question_response_count}",
      "#{((question_response_count / total_response_count) * 100).to_i}%"
    ]
  
end

p_pdf.table(dataset, :border_width => 0, :vertical_padding => 0, :horizontal_padding => 4, :align => { 0 => :right, 1 => :center, 2 => :center})
