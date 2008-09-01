class QuestionsController < ApplicationController 
  before_filter :login_or_survey_invitation_required
  layout :logged_in_or_invited_layout 
  
  def index
    @survey = Survey.find(params[:survey_id])
    @participation = current_organization_or_survey_invitation.participations.find_by_survey_id(@survey.id)
    @responses = @participation.responses if !@participation.nil?
    respond_to do |wants|
      wants.html {
        #Show a different layout if the user is replying with an external survey invitation
        render :layout => 'survey_invitation_logged_in' if invited_to_survey?}
      wants.xml {
         render :xml => @survey.questions.to_xml
      }
    end
    #if the record is not found, try to send the user to the report
    rescue ActiveRecord::RecordNotFound
      respond_to do |wants|
        wants.html do
          flash[:notice] = "The report you are trying to access is closed."
          redirect_to survey_report_path(params[:survey_id])
        end
    end
  end
    
  private
    def logged_in_or_invited_layout
      logged_in? ? "logged_in" : "survey_invitation_logged_in"
    end
    
end
