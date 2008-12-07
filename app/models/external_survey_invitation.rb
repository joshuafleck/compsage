class ExternalSurveyInvitation < ExternalInvitation
  belongs_to :survey
  
  has_many :discussions, :as => :responder
  has_many :participations, :as => :participant
  has_many :responses, :through => :participations
  
  validates_presence_of :survey
  validates_presence_of :organization_name, :message => $DEFAULT_MESSAGE_REQUIRED
  
  attr_accessible :survey, :disccusions, :responses
end
