class Participation < ActiveRecord::Base
  belongs_to :participant, :polymorphic => true
  belongs_to :survey
  
  has_many :responses, :dependent => :destroy
  
  validates_presence_of :participant, :survey
  validates_associated :responses
  
  after_create :create_participant_subscription
  
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
      if attributes.values.join.empty? then
        # didn't respond
        response[question.id].first.destroy if response[question.id] # So, destroy the previous response if it exists
      else
        question_response =  (current_responses.nil? || current_responses.empty?) ? responses.build(:question => question) : current_responses.first
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
  
  def before_update
    # we also want to update the associated records.  We'll assume it's valid by this point
    # as we are validating the associated records.
    responses.each { |r| r.save! if r.changed? }
  end
  
end
