class WageResponse < NumericalResponse
  self.minimum_responses_for_report = 5
  self.field_options.merge!(:size => 10)
  self.report_type = 'wage_field'

  # Set up units.
  self.units = Units.new("format", {'Annually' => 1, 'Hourly' => 2080}, 'Annually')
  before_save :convert_to_standard_units

  def after_find; end; # Enable after find callback by defining this method.
  after_find :convert_from_standard_units

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

  protected

  # Convert to the standard unit before storing in the database, if the response class has units.
  def convert_to_standard_units
    if self.class.units && self.unit then
      self.numerical_response = self.class.units.convert(self.numerical_response, :from => self.unit, :to => self.class.units.standard_unit) 
    end
  end

  # Convert from the standard units to the user-defined units after pulling the response from the database.
  def convert_from_standard_units
    self.raw_numerical_response = self.numerical_response
    if !self.unit.blank? && self.class.units then
      self.numerical_response = self.class.units.convert(self.numerical_response, :from => self.class.units.standard_unit, :to => self.unit) 
    end
  end

end
