require File.dirname(__FILE__) + '/../spec_helper'

describe PredefinedQuestion do

  before(:each) do
    @survey = Factory.create(:survey)
    @question = Factory.create(:question, :survey => @survey)
  end
  
  it "should build questions" do
    @predefined_question = Factory.create(:predefined_question, :name => "PQ 1", 
      :question_hash => [
        {:response_type => "NumericalResponse", :text =>  "question text", :parent_question_index => nil}
      ]) 
      
    @questions = @predefined_question.build_questions(@survey,@question.id)
    @questions.size.should eql(1)
    # make sure parent questions can be specified
    @questions.first.parent_question.should eql(@question)
  end
  
  it "should build parent-child relationships between the PDQ's questions" do
    @predefined_question = Factory.create(:predefined_question, :name => "PQ 1", 
      :question_hash => [
        {:response_type => "NumericalResponse", :text =>  "question text1", :parent_question_index => 0}
      ]) 
      
    @survey.questions.delete_all
    @questions = @predefined_question.build_questions(@survey,nil)
    # make sure follow-up questions can be specified
    @survey.questions.first.parent_question.should eql(@survey.questions.first)
  end
  
  it "should only return questions in which the question is not the child of another question in the same PDQ" do
    @predefined_question = Factory.create(:predefined_question, :name => "PQ 1", 
      :question_hash => [
        {:response_type => "NumericalResponse", :text =>  "question text1", :parent_question_index => nil},
        {:response_type => "NumericalResponse", :text =>  "question text2", :parent_question_index => 0}
      ]) 
      
    @survey.questions.delete_all
    @question = Factory.create(:question, :survey => @survey)
    @questions = @predefined_question.build_questions(@survey,@question.id)
    # make sure we returned the question with no PDQ as the parent
    @questions.size.should eql(1)
    # make sure parent questions can be specified
    @questions.first.parent_question.should eql(@question)
    # make sure the child question was added
    @questions.first.child_questions.first.should_not be_nil
    
  end
  
end
