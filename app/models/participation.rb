class Participation < ActiveRecord::Base
  belongs_to :participant, :polymorphic => true
  belongs_to :survey
  
  has_many :responses
  
  validates_presence_of :participant, :survey
  validates_associated :responses
  
  after_create :create_participant_subscription
  
  named_scope :belongs_to_invitee, 
    :include => [{:survey => [:invitations]}], 
    :conditions => ['participations.participant_type = ? OR (participations.participant_type = ? AND participations.participant_id = surveys.sponsor_id) OR (invitations.invitee_id = participations.participant_id AND participations.participant_type = ?)',
      'Invitation', 
      'Organization', 
      'Organization']  
  
  # sets up the response for this participation.
  def response=(question_response_params)
    new_responses = []
    question_response_params.each do |question_id, attributes|
      next if attributes.values.join.empty?
      question_response = response[question_id] || responses.new(:question_id => question_id)
      question_response.attributes = attributes
      new_responses << question_response
    end
    self.responses = new_responses
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
end
