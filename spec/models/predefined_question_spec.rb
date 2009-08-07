require File.dirname(__FILE__) + '/../spec_helper'

describe PredefinedQuestion do
  before(:each) do
    @survey = Factory.create(:survey)
    @question = @survey.questions.first
    @predefined_question = Factory.create(:predefined_question,
                                          :name => "PQ 1", 
                                          :question_hash => [{
                                            :response_type => "NumericalResponse",
                                            :text =>  "question text",
                                            :parent_question_index => nil
                                          }]) 
  end
  
  it "should set the new question's attributes to be the predefined question's attributes" do
    question = @predefined_question.build_questions(@survey).first
    question.response_class.should == NumericalResponse
    question.text.should == "question text"
  end

  it "should set the new question's PDQ id to the PDQ's ID" do
    question = @predefined_question.build_questions(@survey).first
    question.predefined_question_id.should == @predefined_question.id
  end

  it "should set the new question's parent question to the specified parent question" do
    question = @predefined_question.build_questions(@survey, @question.id).first
    question.parent_question.should == @question
  end

  describe "with a PDQ with one question and no follow-ups." do
    it "should build one question" do
      questions = @predefined_question.build_questions(@survey)
      questions.size.should == 1
    end
  end

  describe "with a PDQ with more than one question and a follow-up" do
    before do
      @predefined_question = Factory.create(:predefined_question, :name => "PQ 1", 
        :question_hash => [
          {:response_type => "NumericalResponse", :text =>  "question text1", :parent_question_index => nil},
          {:response_type => "NumericalResponse", :text =>  "question text2", :parent_question_index => 0}
        ]) 
    end

    it "should build questions" do
      questions = @predefined_question.build_questions(@survey)
      questions.should_not be_empty
    end

    it "should build parent-child relationships between the PDQ's questions" do
      @predefined_question.build_questions(@survey)
      @survey.questions.last.parent_question.should == @survey.questions[1]
    end

    it "should only return questions in which the question is not the child of another question in the same PDQ" do
      questions = @predefined_question.build_questions(@survey, :parent_question => @question)
      questions.size.should == 1
    end

    it "should return a question with a child question" do
      questions = @predefined_question.build_questions(@survey, :parent_question => @question)
      questions.first.child_questions.first.should == @survey.questions.last 
    end
  end
end
