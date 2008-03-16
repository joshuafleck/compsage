class ExternalSurveyInvitation < ExternalInvitation

  belongs_to :survey
  
  has_many :discussions, :dependent => :destroy
  has_many :responses, :dependent => :destroy
  
  validates_presence_of :survey
  validates_presence_of :name
  
end
