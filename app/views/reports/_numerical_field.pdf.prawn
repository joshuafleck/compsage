percentiles = question.responses.percentiles(:numerical_response, 25, 50, 75)

results = [["Average","#{number_with_precision(question.responses.average(:numerical_response))}"]]

if question.adequate_responses_for_percentiles? then
  results << ["25th Percentile","#{number_with_precision(percentiles[0])}"]
  results << ["Median","#{number_with_precision(percentiles[1])}"]
  results << ["75th Percentile","#{number_with_precision(percentiles[2])}"]
end

p_pdf.table(results, :border_width => 0, :vertical_padding => 0, :horizontal_padding => 2, :align => { 0 => :right, 1 => :right})

