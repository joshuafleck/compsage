class Question < ActiveRecord::Base
  belongs_to :survey
  has_many :responses, :dependent => :delete_all, :extend => StatisticsExtension
  has_many :participations, :through => :responses
  acts_as_list :scope => :survey_id
  
  serialize :options
  serialize :textual_response
  
  attr_accessor :included
  
  xss_terminate :except => [ :question_type, :question_parameters, :html_parameters, :options, :custom_question_type ]
  
  validates_presence_of :question_type
  validates_presence_of :options, :message => " are required multiple response question", :if => Proc.new { |question| question.has_options? }
  validates_length_of :text, :within => 1..1000, :message => " is required for a question."
  
  def before_validation_on_create 
     self[:question_type] = CUSTOM_QUESTION_TYPES[self[:custom_question_type]] if attribute_present?("custom_question_type")
     self[:options] = CUSTOM_QUESTION_OPTIONS[self[:custom_question_type]] if attribute_present?("custom_question_type")
  end

  TYPES_WITH_OPTIONS = ['radio', 'checkbox']
  TYPES_WITH_UNITS = ['wage_range','base_wage']

  NUMERICAL_RESPONSES = { 
    'text_field' => false,
    'text_area' => false,
    'numerical_field' => true,
    'radio' => true,
    'checkbox' => false,
    'text' => false,
    'wage_range' => true,
    'base_wage' => true 
  }
  
  MINIMUM_RESPONSES = {
    'text_field' => 1,
    'text_area' => 1,
    'numerical_field' => 3,
    'radio' => 1,
    'checkbox' => 1,
    'text' => 1,
    'wage_range' => 3,
    'base_wage' => 5 
  }
                        
  CUSTOM_QUESTION_TYPES = {
    'Free response' => 'text_area',
    'Pay or wage response' => 'wage_range',
    'Numeric response' => 'numerical_field', 
    'Yes/No' => 'radio', 
    'Agreement scale' => 'radio'
  }
                           
  CUSTOM_QUESTION_OPTIONS = {
    'Yes/No' => ['Yes', 'No'],
    'Agreement scale' => ['Strongly Agree','Agree','Neutral','Disagree','Strongly Disagree']
  }
                        
  QUESTION_UNITS = {
    'wage_range' => ['Annually', 'Hourly'],
    'base_wage' => ['Annually', 'Hourly']
  }
  
  UNIT_CONVERSION_FACTORS = {
    'Annually' => 1,
    'Hourly' => 2080
  }
  
  def answerable?
    return !(self[:question_type] == 'text')
  end
  
  def has_options?
    return TYPES_WITH_OPTIONS.include?(self[:question_type])
  end
  
  def numerical_response?
    return NUMERICAL_RESPONSES[self[:question_type]]
  end
  
  def needs_chart?
    return ['radio', 'checkbox'].include?(self[:question_type])
  end
 
  def has_units?
    return TYPES_WITH_UNITS.include?(self[:question_type])
  end

  def units
    return QUESTION_UNITS[self[:question_type]]
  end

  def grouped_responses
  
    if self[:question_type] == 'checkbox' then    
            
    # because we store multiple responses in a single textual response, 
    # we must extract those out to build the grouped response 
    # TODO: support for checkbox
      
    else
    
      @grouped_responses ||= responses.group_by(&:numerical_response)
      
    end
    
  end
  
  # whether or not the question allows qualification
  def qualify?
    numerical_response? || question_type == "checkbox"
  end
  
  # responses belonging to invitees of the survey
  def invitee_responses
    self.responses.from_invitee
  end
  
  # grouped responses belonging to invitees of the survey
  def grouped_invitee_responses

    if self[:question_type] == 'checkbox' then    
  
      # because we store multiple responses in a single textual response, 
      # we must extract those out to build the grouped response 
      # TODO: support for checkbox
    
    else
    
      @grouped_responses ||= invitee_responses.group_by(&:numerical_response)
      
    end
  end
  
  # returns the minimum number of responses required for the question type
  def minimum_responses
    MINIMUM_RESPONSES[self.question_type] || 1 
  end
  
  # returns true if the question received enough responses to be displayed in the report
  def adequate_responses?
    self.response_count >= self.minimum_responses
  end
  
  # returns true if the question received enough responses from invitees to be displayed in the report
  def adequate_invitee_responses?
    self.invitee_response_count >= self.minimum_responses
  end
  
  # returns the total number of responses
  def response_count
      self.responses.size
  end
  
  # returns the number of responses from invitees
  def invitee_response_count
      self.invitee_responses.size
  end
  
  # The qualifications for this question
  def qualifications
    @qualifications ||= self.responses.collect(&:qualifications).compact
  end
end
