# The Response Class and associated classes capture survey responses from the user. The response value is set using the
# virtual attribute response, which is subsequently saved in the database as either numerical_response or
# textual_response.
#
# == Subclasses ==
# There are currently 6 types of responses:
#
# * Response: Base response class. Not used for actual responses, but encapsulates common behavior needed by any
#             subclasses.
# * NumericalResponse: Basic numeric response.
# * WageResponse: Inherits from NumericalResponse, but stores and formats responses as currency.
# * BaseWageResponse: Inherits from WageResponse, behaves exactly the same except requires more responses to be viewed
#                     on a report.
# * TextualResponse: Any old text input.
# * MultipleChoiceResponse: A response to a question that has multiple options.
# 
# == Configuration of Subclasses ==
# Subclasses make use of a variety of class inheritable accessors to configure common behavior. These accessors may be
# used by the base class to take care of certain functionality, such as assigning and converting units or determining
# if comments can be accepted. The following are the current configuration variables:
# 
# * +Units+: A Unit class that is the units this question can be answered in, for example, Annually or Hourly.
# * +Minimum_responses_for_report+: The minimum number of responses required for the question to show up on a report.
# * +Minimum_responses_for_percentiles+: As above, except for only the percentiles.
# * +Has_options+: Whether the response value must come from the question's options.
# * +Field_type+: The HTML field type this response should be entered in. Examples: 'text_box', or 'radio'.
# * +Field_options+: A hash of attributes to add to the HTML field, eg. {:size => 40}
# * +Accepts_comment+: Whether responses can be qualified with a comment.
# * +Report_type+: The name of the report partial that should be rendered for this response type.
#
# == Response Interface ==
#
# Subclasses may want to define the following custom methods:
#
# === +response=+ ===
# Use this method to override what occurs when the response is set. In this method, you will want to save to either
# +numerical_response+ or +textual_response+, depending on the sort of question. You may also want to format the
# response or remove any extraneous characters. The +response_before_type_cast+ instance variable set to assure the
# user sees the proper value in the input field when an error occurs.
#
# === +response+ ===
# This method is used to pull out the response from the database, eg. either +textual_response+ or
# +numerical_response+.
#
# === +formatted_response+ ===
# The question form will call this method to get the value to use for the forms to display to the user, so if you want
# to do any formatting, eg. turn 1 into $1.00, do it here.
# 
class Response < ActiveRecord::Base
  class_inheritable_accessor :units, :minimum_responses_for_report, :has_options, :field_type, :field_options,
                             :accepts_comment, :report_type, :minimum_responses_for_percentiles

  self.units = nil
  self.minimum_responses_for_report = 1
  self.has_options = false
  self.field_type = 'text_box'
  self.field_options = {:size => 40}
  self.accepts_comment = false
  self.report_type = 'text_field'
  self.minimum_responses_for_percentiles = 5

  belongs_to :question
  belongs_to :participation
  
  validates_presence_of :question
  validates_presence_of :response
  validates_each :unit do |record, attr, value|
    record.errors.add_to_base "#{record.class.units.name.capitalize} not provided" if record.class.units && value.blank?
  end
  validate :follow_up_comment_without_response

  before_save :convert_to_standard_units
  def after_find; end; # Enable after find callback by defining this method.
  after_find :convert_from_standard_units

  named_scope :from_invitee,
    :include => {:participation => [{:survey => [:invitations]}]}, 
    :conditions => ['participations.participant_type = ? OR ' \
                    '(participations.participant_type = ? AND participations.participant_id = surveys.sponsor_id) OR ' \
                    '(invitations.invitee_id = participations.participant_id AND participations.participant_type = ?)',
                      'Invitation', 
                      'Organization', 
                      'Organization']
  
  # Add some rubyish accessors for our boolean class attributes
  class << self
    alias :has_options? :has_options
    alias :accepts_comment? :accepts_comment
  end

  # Raw numerical response is used to store a response value before they are converted to the user-defined units. This
  # is helpful if you want to, for example, run some statistics on a group of responses and then convert the resulting
  # values.
  attr_accessor :raw_numerical_response

  # Here we must override new in order to create an object of the proper type.
  #
  def self.new(*args, &block)
    if args.first.is_a?(Hash) && args.first.has_key?(:type) then
      begin
        klass = args.first[:type].constantize
        if klass < Response then # Don't want other models getting in on this action, just Response children.
          return klass.new(*args, &block)
        end
      rescue
        # Do nothing, can't constantize, that's ok.
      end
    end

    # Otherwise go about our business 
    super
  end

  # This method is called by Rails' form helpers when a validation error is being displayed to the user. For example,
  # if a user entered 'omg i luv cats' for a number field, using +response_before_type_cast+ allows the helper to
  # display the offending text as opposed to 0, the integer that the string would be cast to. Without this method,
  # attempting to display a response form with errors will raise a NoMethodError.
  #
  def response_before_type_cast
    @response_before_type_cast || response
  end

  # Define the setter for our virtual response attribute. The default behavior is simply to store the value in
  # +response_before_type_cast, in case there is a validation error, and store the value in the textual_response field.
  #
  def response=(value)
    @response_before_type_cast = value
    self.textual_response = value
  end

  # Define the getter for our virtual attribute. The default behavior pulls the value for the textual_response field.
  #
  def response
    self.textual_response
  end
  
  def comments=(value)
    if value.blank? then
      self[:comments] = nil
    else
      self[:comments] = value
    end
  end
 
  # Formatted version of the response. The form builder will call this method to set the value of the form fields.
  # Default is no formatting.
  def formatted_response
    self.response
  end
  
  private

  # Validator to make sure that you haven't left a comment without responding to the question.
  # TODO: What about non-follow-up questions? There will be no validation error then it appears.
  def follow_up_comment_without_response
    if !self.question.nil? && self.question.level > 0 && !self.comments.nil? && self.response.nil? then
      errors.add_to_base " You may not comment upon a blank response. Use the parent question to add general comments." 
    end
  end

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
