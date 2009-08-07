class Question < ActiveRecord::Base
  belongs_to :survey
  has_many :child_questions, :class_name => 'Question', :foreign_key => 'parent_question_id', :order => "position", :dependent => :destroy 
  belongs_to :parent_question, :class_name => 'Question'
  has_many :responses, :dependent => :delete_all, :extend => StatisticsExtension
  has_many :participations, :through => :responses
  acts_as_list :scope => 'survey_id=#{survey_id} AND parent_question_id #{parent_question_id.nil? ? "IS NULL" : "="+parent_question_id.to_s}'
  
  serialize :options
  serialize :textual_response

  # strips all HTML tags from fields with user input before saving
  xss_terminate :except => [ :response_type, :question_parameters, :html_parameters, :options, :question_type ]
  
  validates_presence_of :response_type
  validates_presence_of :options, :message => " are required multiple response question", :if => Proc.new { |question| question.response_class.has_options? }
  validates_length_of :text, :within => 1..1000, :message => " is required for a question."
  
  def before_validation_on_create 
     # by default, set pay or wage response types as required for custom questions
     self.required = true if !attribute_present?("predefined_question_id") && self.question_type == 'Pay or wage response'
  end
  
  def before_validation 
    if attribute_present?("question_type") && self.question_type_changed? then
      # be sure to update the response type and options if the custom question type changes
      self.response_type = QUESTION_TYPES[self.question_type] 
      self.options = QUESTION_OPTIONS[self.question_type] 
    end
  end
  
  named_scope :required, :conditions => "required = 1"
                       
  QUESTION_TYPES = {
    'Agreement scale' => 'MultipleChoiceResponse',
    'Text response' => 'TextualResponse',
    'Numeric response' => 'NumericalResponse', 
    'Pay or wage response' => 'WageResponse',
    'Percent' => 'PercentResponse',
    'Yes/No' => 'MultipleChoiceResponse', 
  }
                           
  QUESTION_OPTIONS = {
    'Yes/No' => ['Yes', 'No'],
    'Agreement scale' => ['Strongly Agree','Agree','Neutral','Disagree','Strongly Disagree']
  }
 
  def grouped_responses  
    @grouped_responses ||= responses.group_by(&:numerical_response)     
  end

  # returns the minimum number of responses required for the question type
  def minimum_responses
    self.response_class.minimum_responses_for_report
  end
  
  # returns true if the question received enough responses to be displayed on the report
  def adequate_responses?
    self.responses.count >= self.response_class.minimum_responses_for_report
  end
  
  # returns true if the question received enough responses to be displayed in percentiles on the report
  def adequate_responses_for_percentiles?
    self.responses.count >= self.response_class.minimum_responses_for_percentiles
  end

  # The comments for this question
  def comments
    @comments ||= self.responses.collect(&:comments).compact
  end

  # The class of the type of response this question gathers
  def response_class
    self.response_type.constantize
  end

  # Type of report to render
  def report_type
    response_class.report_type
  end
  
  # Determines if the question_type is Yes or No
  def yes_no?
    return !self.options.nil? && self.options.size == 2 && self.options.first == "Yes" && self.options.last == "No"
  end
  # Determines the level of nesting for the question
  def level
    if !parent_question then
      0 
    else
      parent_question.level + 1
    end
  end
end
