percentiles = question.responses.percentiles(@format == "Hourly" ? "hourly_unit_response" :"annually_unit_response", 25, 50, 75)
units = Units.new("format", {'Annually' => 1, 'Hourly' => 2080}, 'Annually')
average = question.responses.average(:numerical_response)
average = units.convert(average,{:from => "Annually", :to => "Hourly"}) if @format == "Hourly"

p_pdf.table(
  [
    ["Average","#{number_with_precision(average)}"],
    ["25th Percentile","#{number_with_precision(percentiles[0])}"],
    ["Median","#{number_with_precision(percentiles[1])}"],
    ["75th Percentile","#{number_with_precision(percentiles[2])}"]
  ], :border_width => 0, :vertical_padding => 0, :horizontal_padding => 2, :align => { 0 => :right, 1 => :right})

