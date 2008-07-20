require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/1/reports/show" do
  before(:each) do
    @question_1 = mock_model(Question,
      :question_type => 'radio',
      :options => ['Yes', 'No'],
      :responses => [1, 2],
      :text => 'Question 1',
      :grouped_responses => {0 => [1], 1 => [2]}
    )
    
    @question_2 = mock_model(Question,
      :question_type => 'numerical_field',
      :responses => mock('responses_proxy',
        :percentiles => [1, 2, 3],
        :average => 2,
        :size => 3
      ),
      :text => 'Question 2'
    )
    
    # fix some bogus rspec error
    template.stub!(:chart_survey_report_path).and_return("/surveys/1/report/chart")
    @survey = mock_model(Survey, :questions => [@question_1, @question_2], :job_title => 'test')
    assigns[:survey] = @survey
    
    render 'reports/show'
  end
  
  it "should show each question title" do
    response.should have_tag('div.report_question', 'Question 1:')
    response.should have_tag('div.report_question', 'Question 2:')
  end
  
  it "should show a flash graph for each question with options" do
    response.should have_tag('object[id=chart]', 1)
  end
  
  it "should not show questions that are not numberable (like text instructions)"
  it "should show the number of responses for each question"
end
