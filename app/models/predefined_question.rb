class PredefinedQuestion < ActiveRecord::Base
  #position field included to leverage acts_as_list
  acts_as_list
  serialize :question_hash
  attr_accessor :included
  
  # this will build questions based on the predefined question's attributes
  def build_questions(survey)
    self[:question_hash].each do |question_attr|
      question_attr = question_attr.except("id", :id)
      question_attr[:predefined_question_id] = self[:id]
      survey.questions.build(question_attr)
    end
  end
end
