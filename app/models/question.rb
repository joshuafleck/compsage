class Question < ActiveRecord::Base
  belongs_to :survey
  has_many :responses, :dependent => :delete_all, :extend => StatisticsExtension
  acts_as_list :scope => :survey_id
  
  serialize :options
  serialize :textual_response
  
  validates_presence_of :survey
  validates_presence_of :question_type
  validates_presence_of :options, :message => "You must include some options", :if => Proc.new { |question| question.has_options? }
  validates_length_of :text, :within => 1..1000, :message => "A question is required to have associated text."
  
  
  QUESTION_TYPES = [  ["Single-line Text Box", 'text_field'],
                      ["Numerical Input", 'numerical_field'],
                      ["Multi-line Text Box", 'text_area'],
                      ["Multiple Choice - 1 Answer", 'radio'],
                      ["Multiple Choice - Any Answer", 'checkbox'],
                      ["Textual Comments or Instructions", 'text']
                    ]
  TYPES_WITH_OPTIONS = ['radio', 'checkbox']
  NUMERICAL_RESPONSES = { 'text_field' => false,
                                'text_area' => false,
                                'numerical_field' => true,
                                'radio' => true,
                                'checkbox' => false,
                                'text' => false
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
  
end
