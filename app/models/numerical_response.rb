class NumericalResponse < Response
  include ActionView::Helpers::NumberHelper

  self.minimum_responses_for_report = 3
  self.field_options.merge!(:size => 6)
  self.accepts_comment = true
  self.report_type = 'numerical_field'

  validates_numericality_of :response, :allow_nil => true

  def response
    self.numerical_response
  end

  def response=(value)
    value = sanitize_number(value)
    self.numerical_response = @response_before_type_cast = value
  end

  # Simply add commas. 
  def formatted_response
    number_with_delimiter(self.numerical_response)
  end
  
  protected

  # removes dollar signs and commas
  def sanitize_number(value)
    value.respond_to?(:gsub) ? value.gsub(/\$|\,|\%/, '') : value
  end
end
