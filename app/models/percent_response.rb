class PercentResponse < NumericalResponse
  self.field_options.merge!(:size => 4)

  def formatted_response
    "#{self.numerical_response}%"
  end
end
