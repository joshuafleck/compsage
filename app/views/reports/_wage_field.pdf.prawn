percentiles = question.responses.percentiles(:numerical_response, 25, 50, 75)
average = question.responses.average(:numerical_response).to_i / 100.0

if format == "Hourly" then
p_pdf.table(
	  [
	    ["Average","#{number_to_currency(WageResponse.units.convert(average,{:from => "Annually", :to => "Hourly"}))}"],
	    ["25th Percentile","#{number_to_currency(WageResponse.units.convert(percentiles[0].to_i / 100.0,{:from => "Annually", :to => "Hourly"}))}"],
	    ["Median","#{number_to_currency(WageResponse.units.convert(percentiles[1].to_i / 100.0,{:from => "Annually", :to => "Hourly"}))}"],
	    ["75th Percentile","#{number_to_currency(WageResponse.units.convert(percentiles[2].to_i / 100.0,{:from => "Annually", :to => "Hourly"}))}"]
	  ], :border_width => 0, :vertical_padding => 0, :horizontal_padding => 2, :align => { 0 => :right, 1 => :right})
else
  p_pdf.table(
	  [
	    ["Average","#{number_to_currency(average)}"],
	    ["25th Percentile","#{number_to_currency(percentiles[0].to_i / 100.0)}"],
	    ["Median","#{number_to_currency(percentiles[1].to_i / 100.0)}"],
	    ["75th Percentile","#{number_to_currency(percentiles[2].to_i / 100.0)}"]
	  ], :border_width => 0, :vertical_padding => 0, :horizontal_padding => 2, :align => { 0 => :right, 1 => :right})
end

