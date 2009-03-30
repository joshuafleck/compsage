class NumericalResponse < Response
  self.minimum_responses_for_report = 3
  self.field_options.merge!(:size => 5)
  self.accepts_qualification = true

  validates_numericality_of :response, :allow_nil => true

  def response
    self.numerical_response
  end

  def response=(value)
    self.numerical_response = sanitize_number(value)
  end

  private
  # removes dollar signs and commas
  def sanitize_number(value)
    value.respond_to?(:gsub) ? value.gsub(/\$|\,/, '') : value
  end
end
