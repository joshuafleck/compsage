require File.dirname(__FILE__) + '/../spec_helper'
include QuestionsHelper

describe QuestionsHelper do
  def question_attributes
    {
      :text => "question text",
      :markup_text => 'markup text',
      :html_parameters => {},
      :question_parameters => {},
      :options => ["One", "Two"]
    }
  end
  
  before do
    @response = mock_model(Response, :textual_response => 'text_response', :numerical_response => 1, :qualifications => [])
  end
  
  it "should print a text box question without a response" do
    question = mock_model(Question, question_attributes.with(:question_type => 'text_field',
                                                             :numerical_response? => false,
                                                             :has_options? => false))
    print_question(question).should have_tag('div') do
      with_tag('label', question.text)
      with_tag('input[type=text]')
    end
  end
  
  it "should print a text box question with a response" do
    question = mock_model(Question, question_attributes.with(:question_type => 'text_field',
                                                             :numerical_response? => false,
                                                             :has_options? => false))
                                                              
    print_question(question, :responses => [@response]).should have_tag('div') do
      with_tag('label', question.text)
      with_tag("input[type=text][value=#{@response.textual_response}]")
    end
  end
  
  it "should print a numerical text box question" do
    question = mock_model(Question, question_attributes.with(:question_type => 'numerical_field',
                                                             :numerical_response? => true,
                                                             :has_options? => false))
    print_question(question).should have_tag('div') do
      with_tag('label', question.text)
      with_tag('input[type=text]')
    end
  end
  
  it "should print a text area question" do
    question = mock_model(Question, question_attributes.with(:question_type => 'text_area',
                                                              :numerical_response? => false,
                                                              :has_options? => false))
                                                              
    print_question(question, :responses => [@response]).should have_tag('div') do
      with_tag('label', question.text)
      with_tag('textarea', @response.textual_response)
    end
  end
  
  it "should print a radio button question" do
    question = mock_model(Question, question_attributes.with(:question_type => 'radio',
                                                              :numerical_response? => true,
                                                              :has_options? => true))
                                                              
    print_question(question, :responses => [@response]).should have_tag('div') do
      with_tag('p', question.text)      
      with_tag('label', question.options.first) do
        with_tag('input[type=radio]')
      end
      with_tag('label', question.options.last) do
        with_tag('input[type=radio][checked=checked]')
      end
    end
  end
  
  it "should print a check box question" do
    question = mock_model(Question, question_attributes.with(:question_type => 'checkbox',
                                                              :numerical_response? => true,
                                                              :has_options? => true))
                                                              
    print_question(question, :responses => [@response]).should have_tag('div') do
      with_tag('p', question.text)      
      with_tag('label', question.options.first) do
        with_tag('input[type=checkbox]')
      end
      with_tag('label', question.options.last) do
        with_tag('input[type=checkbox][checked=checked]')
      end
    end
  end
  
  it "should print textual instructions" do
    question = mock_model(Question, question_attributes.with(:question_type => 'text',
                                                              :numerical_response? => false,
                                                              :has_options? => false))
                                                              
    print_question(question).should have_tag('div', 'markup text');
  end
  
end