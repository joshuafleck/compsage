class Response < ActiveRecord::Base
  belongs_to :question
  belongs_to :participation
  
  validates_presence_of :question
  validates_presence_of :participation
  validates_presence_of :textual_response, :if => Proc.new { |response| response.numerical_response.blank?}
  validates_presence_of :numerical_response, :if => Proc.new { |response| response.textual_response.blank? }
  validates_numericality_of :numerical_response, :allow_nil => true
  
  #Depending on the type of question, this will return the textual or numerical response
  def get_response 
  	if self.question.numerical_response? == :true
  		self.numerical_response
  	else
  		self.textual_response
  	end
  end
end
