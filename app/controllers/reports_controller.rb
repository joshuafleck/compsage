class ReportsController < ApplicationController
  layout 'logged_in'
  before_filter :login_or_survey_invitation_required, :must_have_responded
  
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
  
  protected
  
  def must_have_responded
    if current_organization_or_survey_invitation.participations.find_by_survey_id(params[:survey_id]).nil? then
       render :text => "You must first respond to the survey before getting results.", :status => :unauthorized
      return false
    end
  end
end
