class QuestionsController < ApplicationController 
  before_filter :login_or_survey_invitation_required
  layout 'logged_in'
  
  def index
    @survey = Survey.find(params[:survey_id])
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
  
end
