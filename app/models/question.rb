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
     self[:question_type] = CUSTOM_QUESTION_TYPES[self[:custom_question_type]] if attribute_present?("custom_question_type")
     self[:options] = CUSTOM_QUESTION_OPTIONS[self[:custom_question_type]] if attribute_present?("custom_question_type")
  end
                       
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

  def answerable?
    return !self.response_type.nil?
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
    self.response_count >= self.response_class.minimum_responses_for_report
  end
  
  # returns true if the question received enough responses from invitees to be displayed in the report
  def adequate_invitee_responses?
    self.invitee_response_count >= self.response_class.minimum_responses_for_report
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

  # The class of the type of response this question gathers
  def response_class
    self.response_type.constantize
  end
end
