xml.instruct!
xml.graph(:caption => "", :decimalPrecision => 0, :animation => 0,
          :bgColor => "FBFAF8",
          :yAxisMaxValue => @question.send(@grouped_responses_method).collect{|k, v| v.size}.max + 1,
          :numdivlines => @question.send(@grouped_responses_method).collect{|k, v| v.size}.max,
          :yAxisName => 'Number of Responses') do
	@question.options.each_with_index do |option, index|
		xml.set :name => option, :value => @question.send(@grouped_responses_method)[index].nil? ? 0 : @question.send(@grouped_responses_method)[index].size
	end
end
