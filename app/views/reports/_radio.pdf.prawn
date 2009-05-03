dataset = []

question.options.each_with_index do |option, index|

  dataset[index] = 
    [
      "#{option}",
      "#{question.send(@grouped_responses_method)[index.to_f].nil? ? 0 : question.send(@grouped_responses_method)[index.to_f].size}"
    ]
  
end

p_pdf.table(dataset, :border_width => 0, :padding => 1)
