class WageResponse < NumericalResponse
  self.units = Units.new("format", {'Annual' => 1, 'Hourly' => 2080}, 'Annual')
  def response
    "$#{"%.2f" % self.numerical_response}" if self.numerical_response
  end
end
