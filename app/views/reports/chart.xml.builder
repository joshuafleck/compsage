xml.instruct!
xml.graph(:caption => "", :decimalPrecision => 0) do
	@question.options.each_with_index do |option, index|
		xml.set :name => option, :value => @question.grouped_responses[index].nil? ? 0 : @question.grouped_responses[index].size
	end
end