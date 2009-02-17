class QuestionsController < ApplicationController 
  before_filter :login_or_survey_invitation_required
  layout :logged_in_or_invited_layout 
  
  def index
    @survey = Survey.find(params[:survey_id])
    @participation = current_organization_or_survey_invitation.participations.find_or_initialize_by_survey_id(@survey.id)
    respond_to do |wants|
      wants.html
      wants.xml { render :xml => @survey.questions.to_xml }
    end
  end
  
  def preview
    @survey = Survey.find(params[:survey_id])
    @participation = Participation.new
  end
    
end
