class MultipleChoiceResponse < Response
  self.field_type = 'radio'
  self.has_options = true
  self.accepts_qualification = true
end
