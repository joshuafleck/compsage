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
  #
  # Note: Checkboxes are handled by creating multiple responses to the same question.  This allows
  # for easy generation of statistics straight from the DB, but has some pretty poor code side
  # effects.  For example, the respondant's qualifications are stored with whatever the first
  # response is, ordered by option choice.  This is a little finicky, but works for now.
  
  def response=(question_response_params)
    survey.questions.each do |question|
      attributes = question_response_params[question.id.to_s]
      current_responses = response[question.id]
      if question.question_type == 'checkbox' then
        # We need to handle multiple responses.  The numerical response attributes hould be an
        # array of option values (eg. indexes).
        checked_options = attributes[:numerical_response]
        
        question.options.each_index do |index|
          current_response = current_responses.find{|r| r.numerical_response == index} unless current_responses.nil?
          checked = checked_options.include?(index.to_s)
          p "For #{index}, checked is #{checked} and current_response is #{current_response.inspect}"
          if checked && current_response.nil? then
            p "#{index} is checked and current_response doesn't exist.  making new response."
            # Need to make a new response
            responses.build(:question => question, :numerical_response => index)
          elsif !checked && !current_response.nil? then
            p "#{index} is not checked and current response exists."
            # Need to destroy the response as it is no longer checked.
            current_response.destroy
          end
          
          # Nothing is done when 'checked and current response not nil' and 'not checked and
          # current response is nil') since everything is as it should be.
        end
        
        if !attributes[:qualifications].blank? then
          # assign the qualifications.  This is crufty.
          sorted_responses = responses.sort {|r1, r2| r1.numerical_response <=> r2.numerical_response}
          sorted_responses.first.qualifications = attributes[:qualifications]
        end
      else
        if attributes.values.join.empty? then
          # didn't respond
          response[question.id].first.destroy if response[question.id] # So, destroy the previous response if it exists
        else
          question_response =  (current_responses.nil? || current_responses.empty?) ? responses.build(:question => question) : current_responses.first
          question_response.attributes = attributes
        end
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
