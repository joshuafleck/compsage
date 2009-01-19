class Response < ActiveRecord::Base
  belongs_to :question
  belongs_to :participation
  
  validates_presence_of :question
  validates_presence_of :response
  validates_numericality_of :response, :if => Proc.new { |r| !r.question.nil? && r.question.numerical_response? },
    :message => "must be a number", :allow_nil => true

  HUMANIZED_ATTRIBUTES = {
    :numerical_response => "Response",
    :textual_response => "Response"
  }
 

  named_scope :from_invitee,
    :include => {:participation => [{:survey => [:invitations]}]}, 
    :conditions => ['participations.participant_type = ? OR (participations.participant_type = ? AND participations.participant_id = surveys.sponsor_id) OR (invitations.invitee_id = participations.participant_id AND participations.participant_type = ?)',
      'Invitation', 
      'Organization', 
      'Organization']
  
  #Depending on the type of question, this will return the textual or numerical response
  def response
  	question.numerical_response? ? numerical_response : textual_response unless question.nil?
  end
  
  def response_before_type_cast
    @response_before_type_cast || response
  end

  def response=(value)
    value = sanitize_number(value)
    @response_before_type_cast = value
    if !question.nil? && question.numerical_response? then
      self.numerical_response = value
    else
      self.textual_response = value
    end
  end

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  private

  # removes dollar signs and commas
  def sanitize_number(value)
    value.gsub(/\$|\,/, '')
  end
end
