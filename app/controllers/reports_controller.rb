class ReportsController < ApplicationController
  layout :logged_in_or_invited_layout 
  before_filter :login_or_survey_invitation_required, :must_have_responded_or_sponsored
  
  def show
    @survey = Survey.finished.find(params[:survey_id])
    @invitations = @survey.all_invitations(true)
    @participations = @survey.participations
    @total_participation_count = @participations.size
    
    respond_to do |wants|
      wants.html
      wants.pdf { render :layout => false }
    end
    
  end
  
  # for for flash charts
  def chart
    @question = Question.find(params[:question_id])
    @survey = @question.survey
    @participations = @survey.participations
    @total_participation_count = @participations.size
    
    respond_to do |wants|
      wants.xml { render(:layout => false) }
    end
  end
  
  #email the admins the report of a suspected result along with comment.
  def suspect
    @survey = Survey.finished.find(params[:survey_id])
    Notifier.deliver_report_suspect_results_notification(@survey, params[:comment])
    
    respond_to do |wants|
      wants.json do
        render :json => "successful!"
      end
    end
  end
  
  protected
  
  def must_have_responded_or_sponsored
    @survey = Survey.finished.find(params[:survey_id])
    if (current_organization_or_survey_invitation.participations.find_by_survey_id(@survey.id).nil? &&
      current_organization != @survey.sponsor) 
    then
      respond_to do |wants|
        wants.html do
          flash[:notice] = "The response deadline has passed. You may not view the results unless you have responded to the survey."
          if logged_in_from_survey_invitation? then
            redirect_to new_account_path
          else
            redirect_to surveys_path
          end
        end
        wants.xml do
          render :text => "You must first respond to the survey before getting results.", :status => :unauthorized
        end
      end
       
      return false
    end
  end
     
end
