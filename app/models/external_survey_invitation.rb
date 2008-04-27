class ExternalSurveyInvitation < ExternalInvitation
  belongs_to :survey
  
  has_many :discussions, :as => :responder
  has_many :responses, :as => :responder
  
  validates_presence_of :survey
  validates_presence_of :name
  
  attr_accessible :survey, :disccusions, :responses
  
end
