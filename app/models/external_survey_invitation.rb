class ExternalSurveyInvitation < ExternalInvitation
  belongs_to :survey
  
  has_many :discussions, :as => :responder
  has_one :participation, :as => :participant
  has_many :responses, :through => :participations
  
  validates_presence_of :survey
  validates_presence_of :name
  
  attr_accessible :survey, :disccusions, :responses
  
end
