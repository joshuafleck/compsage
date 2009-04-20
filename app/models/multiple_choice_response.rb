class MultipleChoiceResponse < NumericalResponse
  self.field_type = 'radio'
  self.has_options = true
  self.accepts_qualification = true
  self.report_type = 'radio'

  def response=(value)
    self.numerical_response = value
  end
end
