class PredefinedQuestion < ActiveRecord::Base
  #position field included to leverage acts_as_list
  acts_as_list
  serialize :question_hash

  xss_terminate :except => [ :question_hash ]
  
  # this will build questions based on the predefined question's attributes
  def build_questions(survey)
  
    questions = [];
    
    self[:question_hash].each do |question_attr|
    
      question_attr = question_attr.except("id", :id)
      question_attr[:predefined_question_id] = self[:id]
      
      questions << survey.questions.create(question_attr) 
          
    end
    
    # now that all of the questions have been created, set up the parent/child dependancies
    questions.each do |question|
      
      if !question.parent_question_index.blank? then
      
        question.parent_question_id = questions[question.parent_question_index].id
        question.save
        
      end
      
    end
    
    questions
    
  end

end
