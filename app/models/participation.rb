class Participation < ActiveRecord::Base
  belongs_to :participant, :polymorphic => true
  belongs_to :survey
  
  has_many :responses, :dependent => :destroy, :validate => false
  
  validates_presence_of :participant, :survey
  validates_presence_of :responses, :message => "must be provided"
  validates_associated :responses, :message => "may have errors. Check your responses for errors highlighted in red."
  before_validation :required_responses_present, :parent_responses_present
  
  after_create :create_participant_subscription, :fulfill_invitation
  before_update :save_responses

  named_scope :recent,
    :include => :survey,
    :conditions => ['surveys.aasm_state = ? OR (surveys.aasm_state = ? AND surveys.end_date > ?)',
                    'running',
                    'stalled',
                    Time.now - 1.day]
  named_scope :not_sponsored_by, lambda { |o| {:include => :survey, :conditions => ['surveys.sponsor_id <> ?', o.id]} }
  
  # Sets up the response for this participation from the form parameters.  
  def response=(question_response_params)
    self.survey.questions.each do |question|
      attributes = question_response_params[question.id.to_s] || {}
      current_responses = response[question.id]
      if attributes[:response].blank? && attributes[:comments].blank? then
        # didn't respond
        if !(current_responses.nil? || current_responses.empty?) then
          current_responses.first.destroy # Destroy the previous response if it exists
        end
      else
        question_response = if current_responses.nil? || current_responses.empty? then
                              # Build a new response to save assuming all goes well.
                              responses.build(:question => question, :type => question.response_type)
                            else
                              # Otherwise, use the current response.
                              current_responses.first
                            end
        question_response.attributes = attributes
      end
    end
  end
  
  def response
    responses.group_by(&:question_id)
  end
  
  # After participation is created this will transtition the status of the users invitation 
  # to fufilled so it will no longer be listed among the users current survey invitations.
  def fulfill_invitation
    if self.participant.is_a?(Organization) then
      invitation = self.participant.survey_invitations.find_by_survey_id(self.survey.id)
      invitation.fulfill! unless invitation.nil?
    end
  end
  
  # Makes a subscription to the survey which allows us to link a participation to it's
  # responded surveys, regardless of membership type.
  def create_participant_subscription
    if self.participant.is_a?(Organization) && self.survey.sponsor != self.participant then
      s = SurveySubscription.create!(
        :organization => self.participant,
        :survey => self.survey,
        :relationship => 'participant'
      )
    end
  end
    
  private
  # Called after creation to add a subscription.
  
  def save_responses
    # we also want to update the associated records.  We'll assume it's valid by this point
    # as we are validating the associated records. We don't want to save frozen responses
    # as they are likely deleted at this point.
    responses.each { |r| r.save! if !r.frozen? && r.changed? }
  end  
  
  # Adds a blank response to each required question to ensure validation fails if there is no response
  # Validation fails, so deletion gets rolled back, so building dummy for validation failure creates duplicate question. 
  def required_responses_present
    return if survey.nil?
    # Find all of our responses, weeding out the responses that are frozen.
    questions_with_responses = collect_responses
    self.survey.questions.required.each do |question|
      # Skip required questions where there's a parent question and it isn't answered, or there is a parent question
      # and it's a yes/no with a no response.
      next if !question.parent_question.nil? && (!questions_with_responses.include?(question.parent_question_id) || 
                                                 (question.parent_question.yes_no? && response[question.parent_question_id].first.response.to_i == 1))

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
    # Find all of our responses, weeding out the responses that are frozen.
    questions_with_responses = collect_responses
    self.responses.each do |response|
      if response.question.parent_question &&
         !questions_with_responses.include?(response.question.parent_question_id) then
        # There is a parent question and the current set of responses doesn't include the parent question.
        responses.build(:question => response.question.parent_question, :type => response.question.parent_question.response_type)
      end
    end
  end
  
  def collect_responses
    self.responses.reject{|r| r.frozen?}.collect(&:question_id)
  end
end
