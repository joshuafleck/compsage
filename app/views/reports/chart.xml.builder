xml.instruct!
xml.graph(:caption => "", :decimalPrecision => 0) do
	@question.options.each_with_index do |option, index|
		xml.set :name => option, :value => @question.send(@grouped_responses_method)[index].nil? ? 0 : @question.send(@grouped_responses_method)[index].size
	end
end
