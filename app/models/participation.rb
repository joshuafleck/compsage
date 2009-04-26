class Participation < ActiveRecord::Base
  belongs_to :participant, :polymorphic => true
  belongs_to :survey
  
  has_many :responses, :dependent => :destroy, :validate => false
  
  validates_presence_of :participant, :survey
  validates_presence_of :responses, :message => "must be provided"
  validates_associated :responses, :message => "may have errors. Check your responses for errors highlighted in red."
  validate :required_responses_present
  
  after_create :create_participant_subscription, :fulfill_invitation
  
  named_scope :belongs_to_invitee, 
    :include => [{:survey => [:invitations]}], 
    :conditions => ['participations.participant_type = ? OR (participations.participant_type = ? AND participations.participant_id = surveys.sponsor_id) OR (invitations.invitee_id = participations.participant_id AND participations.participant_type = ?)',
      'Invitation', 
      'Organization', 
      'Organization']  
  
  # Sets up the response for this participation from the form parameters.  
  def response=(question_response_params)
    survey.questions.each do |question|
      attributes = question_response_params[question.id.to_s] || {}
      current_responses = response[question.id]
      if attributes[:response].blank? && attributes[:qualifications].blank? then
        # didn't respond
        response[question.id].first.destroy if response[question.id] # So, destroy the previous response if it exists
      else
        question_response =  (current_responses.nil? || current_responses.empty?) ? responses.build(:question => question, :type => question.response_type) : current_responses.first 
        question_response.attributes = attributes
      end
    end
  end
  
  def response
    responses.group_by(&:question_id)
  end
  
  protected
  
  def create_participant_subscription
    if participant.is_a?(Organization) && survey.sponsor != participant then
      s = SurveySubscription.create!(
        :organization => participant,
        :survey => survey,
        :relationship => 'participant'
      )
    end
  end
  
  def fulfill_invitation
    if participant.is_a?(Organization) then
      invitation = self.participant.survey_invitations.find_by_survey_id(self.survey.id)
      invitation.fulfill! unless invitation.nil?
    end
  end
  
  def before_update
    # we also want to update the associated records.  We'll assume it's valid by this point
    # as we are validating the associated records.
    responses.each { |r| r.save! if r.changed? }
  end  
  
  private
  
  # adds a blank response to each required question to ensure validation fails if there is no response
  def required_responses_present
    self.survey.questions.required.each do |question|
      if !self.responses.collect(&:question_id).include?(question.id) then
        responses.build(:question => question, :type => question.response_type)
      end
    end if survey
  end
end
