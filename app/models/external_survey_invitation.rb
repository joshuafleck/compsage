class ExternalSurveyInvitation < ExternalInvitation
  belongs_to :survey
  
  has_many :discussions, :as => :responder
  has_many :participations, :as => :participant
  has_many :responses, :through => :participations
  
  validates_presence_of :survey
  validates_presence_of :organization_name
  
  attr_accessible :survey, :disccusions, :responses
  
 
  def validate_on_create
    validate_not_invited if survey
  end
  
  private
  
  def validate_not_invited
    errors.add_to_base "Invitee is already invited" if survey.external_invitations.collect(&:email).include?(email)
  end  
end
