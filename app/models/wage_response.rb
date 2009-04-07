class WageResponse < NumericalResponse
  self.units = Units.new("format", {'Annually' => 1, 'Hourly' => 2080}, 'Annually')
  def formatted_response
    number_to_currency(self.numerical_response) if self.numerical_response
  end
end
