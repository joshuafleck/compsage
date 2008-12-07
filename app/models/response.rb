class Response < ActiveRecord::Base
  belongs_to :question
  belongs_to :participation
  
  validates_presence_of :question
  validates_presence_of :textual_response, :if => Proc.new { |response| response.numerical_response.blank?}
  validates_presence_of :numerical_response, :if => Proc.new { |response| response.textual_response.blank? }
  validates_numericality_of :numerical_response, :allow_nil => true, :message => "Only numbers are valid."
  HUMANIZED_ATTRIBUTES = {
    :numerical_response => "",
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
end
