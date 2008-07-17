class QuestionsController < ApplicationController 
  before_filter :login_or_survey_invitation_required
  
  def index
    @survey = Survey.find(params[:survey_id])
    respond_to do |wants|
      wants.html {}
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
