class Participation < ActiveRecord::Base
  belongs_to :participant, :polymorphic => true
  belongs_to :survey
  
  has_many :responses, :dependent => :destroy, :validate => false
  
  validates_presence_of :participant, :survey
  validates_presence_of :responses, :message => "must be provided"
  validates_associated :responses, :message => "may have errors. Check your responses for errors highlighted in red."
  before_validation :required_responses_present, :parent_responses_present
  
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
  
  # Adds a blank response to each required question to ensure validation fails if there is no response
  # 
  def required_responses_present
    return if survey.nil?

    questions_with_responses = self.responses.collect(&:question_id)
    self.survey.questions.required.each do |question|
      # Skip required questions where there's a parent question and it isn't answered.
      next if !question.parent_question.nil? && questions_with_responses.include?(question.parent_question_id)

      # If the current question isn't answered, create a dummy question that will fail validation.
      if !questions_with_responses.include?(question.id) then
        responses.build(:question => question, :type => question.response_type)
      end
    end
  end

  # Create a blank response to each parent question of responses if they don't exist to ensure that the user cannot
  # answer a follow-up question without it's parent.
  #
  def parent_responses_present
    return if survey.nil?

    questions_with_responses = self.responses.collect(&:question_id)
    self.responses.each do |response|
      if response.question.parent_question &&
         !questions_with_responses.include?(response.question.parent_question_id) then
        # There is a parent question and the current set of responses doesn't include the parent question.
        responses.build(:question => response.question.parent_question, :type => response.question.parent_question.response_type)
      end
    end
  end
end
