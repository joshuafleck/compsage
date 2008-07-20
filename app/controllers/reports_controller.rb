class ReportsController < ApplicationController
  layout 'logged_in'
  
  def show
    @survey = Survey.find(params[:survey_id])
  end
  
  # for for flash charts
  def chart
    @question = Question.find(params[:question_id])
    respond_to do |wants|
      wants.xml { render(:layout => false) }
    end
  end
end
