class WageResponse < NumericalResponse
  self.field_options.merge!(:size => 10)
  self.units = Units.new("format", {'Annually' => 1, 'Hourly' => 2080}, 'Annually')

  def formatted_response
    number_to_currency(self.response) if self.response
  end

  # We store wage responses as integer values of cents in order to prevent precision problems.
  def response
    self.numerical_response.to_i / 100.0 if self.numerical_response
  end

  def response=(value)
    value = sanitize_number(value)
    @response_before_type_cast = value
    if value.blank? then
      self.numerical_response = nil
    else
      self.numerical_response = (value.to_f * 100).to_i # passing in a blank response here converts to 0.0
    end
  end
end
