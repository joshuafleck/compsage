class Question < ActiveRecord::Base
  belongs_to :survey
  has_many :responses, :dependent => :delete_all
  acts_as_list :scope => :survey_id
  
  serialize :options
  
  validates_presence_of :survey
  validates_presence_of :question_type
  validates_presence_of :options, :message => "You must include some options", :if => Proc.new { |question| question.has_options? }
  validates_length_of :text, :within => 1..1000, :message => "A question is required to have associated text."
  
  
  QUESTION_TYPES = [  ["Single-line Text Box", 'text_field'],
                      ["Numerical Input", 'numerical_field'],
                      ["Multi-line Text Box", 'text_area'],
                      ["Multiple Choice - 1 Answer", 'radio'],
                      ["Multiple Choice - Any Answer", 'check'],
                      ["Textual Comments or Instructions", 'text']
                    ]
  TYPES_WITH_OPTIONS = ['radio', 'check']
  NUMERICAL_RESPONSES = { 'text_field' => false,
                                'text_area' => false,
                                'numerical_field' => true,
                                'radio' => true,
                                'check' => true,
                                'text' => false
                        }
  DEFAULT_HTML_ATTRIBUTES = { 'text_field' => {:size => 30},
                              'numerical_field' => {:size => 6},
                              'text_area' => {  :rows => 3,
                                                :cols => 40},
                              'radio' => {},
                              'check' => {},
                              'text' => {}
                            }
  DEFAULT_QUESTION_ATTRIBUTES = { 'text_field' => {},
                                  'numerical_field' => {},
                                  'text_area' => {:style => 'vertical'},
                                  'radio' => {},
                                  'check' => {},
                                  'text' => {}
                                }
  DEFAULT_OPTIONS = {
    'Yes/No' => ['Yes', 'No'],
    'True/False' => ['True', 'False'],
    '5 Point Agreement' => ['Strongly Agree', 'Agree', 'Neutral', 'Disagree', 'Strongly Disagree'],
    'Extent Observed' => ['Always Observe', 'Often Observe', 'Sometimes Observe', 'Seldom Observe', 'Never Observe'],
    '7 Point Agreement' => ['7 - Highest Agreement', '6', '5', '4', '3','2','1 - Lowest Agreement']
  }
  
  def answerable?()
    return !(self[:question_type] == 'text')
  end
  
  def has_options?()
    return TYPES_WITH_OPTIONS.include?(self[:question_type])
  end
  
  def numerical_response?()
    return NUMERICAL_RESPONSES[self[:question_type]]
  end
  
end
