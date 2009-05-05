xml.instruct!
xml.graph(:caption => "", :decimalPrecision => 0, :animation => 0,
          :bgColor => "FBFAF8",
          :showBarShadow => 0,
          :showNames => 1,
          :yAxisMaxValue => @question.grouped_responses.collect{|k, v| v.size}.max + 1,
          :numdivlines => @question.grouped_responses.collect{|k, v| v.size}.max,
          :yAxisName => 'Number of Responses') do
	@question.options.each_with_index do |option, index|
    xml.set :name => truncate(option, 30), :color => cycle_gradient(
        :start_color => "06385d", 
        :end_color => "7bc5fc", 
        :count => @question.options.size),
      :value => @question.grouped_responses[index.to_f].nil? ? 0 : @question.grouped_responses[index.to_f].size
	end
end
