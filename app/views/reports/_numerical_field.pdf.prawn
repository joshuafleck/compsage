percentiles = question.send(@responses_method).percentiles(:numerical_response, 25, 50, 75)

p_pdf.table(
  [
    ["Average","#{number_with_precision(question.send(@responses_method).average(:numerical_response))}"],
    ["25th Percentile","#{number_with_precision(percentiles[0])}"],
    ["Median","#{number_with_precision(percentiles[1])}"],
    ["75th Percentile","#{number_with_precision(percentiles[2])}"]
  ], :border_width => 0, :vertical_padding => 0, :horizontal_padding => 2, :align => { 0 => :right, 1 => :right})

