class MultipleChoiceResponse < Response
  self.field_type = 'radio'
  self.has_options = true
  self.accepts_comment = true
  self.report_type = 'radio'

  def response=(value)
    self.numerical_response = value
  end

  def response
    self.numerical_response
  end
end
