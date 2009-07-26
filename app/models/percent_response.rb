class PercentResponse < NumericalResponse
  self.field_options.merge!(:size => 4)

  def formatted_response
    "#{number_with_delimiter(self.numerical_response)}%" unless self.numerical_response.blank?
  end
end
