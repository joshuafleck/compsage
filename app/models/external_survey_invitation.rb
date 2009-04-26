class ExternalSurveyInvitation < ExternalInvitation
  belongs_to :survey
  
  has_many :discussions, :as => :responder
  has_many :participations, :as => :participant
  has_many :responses, :through => :participations
  
  validates_presence_of :survey
  validates_presence_of :organization_name
  validate_on_create :not_already_invited
  
  attr_accessible :survey, :disccusions, :responses
  
  private
  
  # adds an error if the email address was already invited
  def not_already_invited
    errors.add_to_base "Invitee is already invited" if survey && survey.external_invitations.collect(&:email).include?(email)
  end  
end
