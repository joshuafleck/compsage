class NumericalResponse < Response
  include ActionView::Helpers::NumberHelper

  self.minimum_responses_for_report = 3
  self.field_options.merge!(:size => 8)
  self.accepts_qualification = true

  validates_numericality_of :response, :allow_nil => true

  def response
    self.numerical_response
  end

  def response=(value)
    value = sanitize_number(value)
    self.numerical_response = @response_before_type_cast = value
  end

  def formatted_response
    number_with_delimiter(self.numerical_response)
  end

  private
  # removes dollar signs and commas
  def sanitize_number(value)
    value.respond_to?(:gsub) ? value.gsub(/\$|\,|\%/, '') : value
  end
end
