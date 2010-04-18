class ExternalSurveyInvitation < ExternalInvitation
  belongs_to :survey
  
  has_many :discussions, :as => :responder
  has_many :participations, :as => :participant
  has_many :responses, :through => :participations
  
  validates_presence_of :survey
  validate_on_create :not_already_invited

  state_machine 'aasm_state', :initial => :pending do
    after_transition :pending => :sent, :do => :send_invitation_email

    event :send_invitation do
      transition :pending => :sent
    end
    
    event :fulfill do
      transition :sent => :fulfilled
    end    
  end
  
  # When an external survey invitation is used to create a new account, its participations and discussions must be moved to the 
  # new account. Once that is complete, the external invitation can be converted to an internal invitation, so
  # that the account is invited to the survey.
  #
  def accept!(organization)
  
    # Move the participation to the new organization, and create a survey subscription
    if self.participations.count > 0 then
      participation = self.participations.first
      organization.participations << participation    
      participation.reload
      participation.create_participant_subscription
    end

    # Move any discussions to the new organization
    self.discussions.each do |discussion|
      organization.discussions << discussion 
    end  
    
    # Convert this invitation to a survey invitation
    self.type = 'SurveyInvitation'
    self.save!   
     
    # Invites this organization to the survey
    organization.survey_invitations << SurveyInvitation.find(self.id)      
    
  end
 
  private
  
  # adds an error if the email address was already invited
  def not_already_invited
    errors.add_to_base "That organization is already invited" if survey && survey.external_invitations.collect(&:email).include?(email)
  end  

  def send_invitation_email
    Notifier.deliver_external_survey_invitation_notification(self)
  end
end
