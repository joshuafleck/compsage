class PredefinedQuestion < ActiveRecord::Base
  acts_as_list
  serialize :question_hash
  validates_presence_of :name

  xss_terminate :except => [ :question_hash ]
  
  named_scope :system_wide, :conditions => "association_id is NULL"
  
  # Build questions for the given +Survey+ from this +PredefinedQuestion+. Predefined questions may be composed of more
  # than one question. In such cases, this method will create multiple +Questions+, returning only the top-level
  # +questions+. +Questions+ that are follow-ups to another created question will not be returned, which will allow the
  # returned question array to be rendered easily with our question partial.
  #
  # ==== Options
  # +parent_question+:: The question that all new questions should be a follow up to.
  #
  def build_questions(survey, parent_question_id = nil, required = nil)

    new_questions = [];
    
    # The question hash is an array of question attribute hashes, one for each question that should be created by this
    # predefined question. So, loop through the question attributes and build the survey questions.
    self.question_hash.each do |question_attributes|
      question_attributes[:predefined_question_id] = self.id
      parent_question_index = question_attributes.delete(:parent_question_index)

      # If the PDQ isn't a follow-up to another PDQ and a parent question is specified, set the parent question to the
      # specified parent question. Otherwise, if the PDQ has a parent question index, set the parent question to the
      # already built parent question.
      if parent_question_index.nil? && !parent_question_id.blank? then
        question_attributes[:parent_question_id] = parent_question_id
      elsif !parent_question_index.nil? then
        question_attributes[:parent_question] = new_questions[parent_question_index]
      end
      
      if !required.nil? then
        question_attributes[:required] = required
      end

      new_questions << survey.questions.create(question_attributes) 
    end

    # Return questions whose level is the same as the first question. This will effectively return all the questions
    # created from the PDQ that aren't specified as follow-ups.
    return new_questions.find_all { |q| q.level == new_questions.first.level }
  end
  
  # Takes a Question and hashes it to work with a PredefinedQuestion
  # question_hash attribute. This can be extended in the future to take a hash of
  # Question objects which have a parent/child relationship for related questions.
  def question=(question)
    question_attributes = {}
    #take the elements we need and throw them into a hash
    question_attributes[:question_type] = question.question_type
    question_attributes[:text] = question.text
    if !question.required.nil? then
      question_attributes[:required] = question.required
    end
  
    #save the hash into another hash.
    self.question_hash = [question_attributes]
  end
  
  # Returns a Question object generated from the question_hash attribute
  def question
    #pull the elements out of the hash as needed
    self.question_hash.each do |question_attributes|
      #add the attributes to a new Question object
      return Question.new(question_attributes)
    end
  end

end
