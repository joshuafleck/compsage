class Response < ActiveRecord::Base
  belongs_to :question
  belongs_to :participation
  
  validates_presence_of :question
  validates_numericality_of :numerical_response, :allow_nil => true, :message => ": Only numbers are valid."
  validates_presence_of :response

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
  	question.numerical_response? ? numerical_response : textual_response
  end
  
  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

end
