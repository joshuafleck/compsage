class Question < ActiveRecord::Base
  belongs_to :survey
  has_many :responses, :dependent => :delete_all, :extend => StatisticsExtension
  has_many :participations, :through => :responses
  acts_as_list :scope => :survey_id
  
  serialize :options
  serialize :textual_response
  
  attr_accessor :included
  
  xss_terminate :except => [ :response_type, :question_parameters, :html_parameters, :options, :custom_question_type ]
  
  validates_presence_of :response_type
  validates_presence_of :options, :message => " are required multiple response question", :if => Proc.new { |question| question.response_class.has_options? }
  validates_length_of :text, :within => 1..1000, :message => " is required for a question."
  
  def before_validation_on_create 
     self[:response_type] = CUSTOM_QUESTION_TYPES[self[:custom_question_type]] if attribute_present?("custom_question_type")
     self[:options] = CUSTOM_QUESTION_OPTIONS[self[:custom_question_type]] if attribute_present?("custom_question_type")
  end
                       
  CUSTOM_QUESTION_TYPES = {
    'Agreement scale' => 'MultipleChoiceResponse',
    'Text response' => 'TextualResponse',
    'Numeric response' => 'NumericalResponse', 
    'Pay or wage response' => 'WageResponse',
    'Percent' => 'PercentResponse',
    'Yes/No' => 'MultipleChoiceResponse', 
  }
                           
  CUSTOM_QUESTION_OPTIONS = {
    'Yes/No' => ['Yes', 'No'],
    'Agreement scale' => ['Strongly Agree','Agree','Neutral','Disagree','Strongly Disagree']
  }
  
  named_scope :required, :conditions => "required = 1"

  def answerable?
    return !self.response_type.nil?
  end
 
  def grouped_responses  
    @grouped_responses ||= responses.group_by(&:numerical_response)     
  end
  
  # responses belonging to invitees of the survey
  def invitee_responses
    self.responses.from_invitee
  end
  
  # grouped responses belonging to invitees of the survey
  def grouped_invitee_responses
    @grouped_responses ||= invitee_responses.group_by(&:numerical_response)
  end
  
  # returns the minimum number of responses required for the question type
  def minimum_responses
    self.response_class.minimum_responses_for_report
  end
  
  # returns true if the question received enough responses to be displayed in the report
  def adequate_responses?
    self.responses.count >= self.response_class.minimum_responses_for_report
  end
  
  # returns true if the question received enough responses from invitees to be displayed in the report
  def adequate_invitee_responses?
    self.invitee_responses.count >= self.response_class.minimum_responses_for_report
  end
  
  # The qualifications for this question
  def qualifications
    @qualifications ||= self.responses.collect(&:qualifications).compact
  end

  # The class of the type of response this question gathers
  def response_class
    self.response_type.constantize
  end

  # Type of report to render
  def report_type
    response_class.report_type
  end
end
