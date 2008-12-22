class Response < ActiveRecord::Base
  belongs_to :question
  belongs_to :participation
  
  validates_presence_of :question
  validate :validate_response
  validates_numericality_of :numerical_response, :allow_nil => true, :message => ": Only numbers are valid."
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
  def get_response 
  	if self.question.numerical_response? == true
  		self.numerical_response
  	else
  		self.textual_response
  	end
  end
  
  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  #check if there this response has been fielded, and yield the proper error message.
  def validate_response
    if self.numerical_response.blank? && self.textual_response.blank? then
      errors.add_to_base("A response is required") unless !self.qualifications.blank?
      errors.add_to_base("You must enter a response to qualify!") unless self.qualifications.blank?
    end
  end
  
  def qualification_requires_response
    errors.add_to_base("You must enter a response to qualify!") unless self.qualifications.blank? || !self.textual_response.blank? || !self.numerical_response.blank?
  end
end
