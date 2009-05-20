class QuestionsController < ApplicationController 
  before_filter :login_or_survey_invitation_required
  layout :logged_in_or_invited_layout 

  ssl_required :index

  def index
    @survey = Survey.running.find(params[:survey_id])
    @participation = current_organization_or_survey_invitation.participations.find_or_initialize_by_survey_id(@survey.id)
    respond_to do |wants|
      wants.html
      wants.xml { render :xml => @survey.questions.to_xml }
    end
  end
  
  def preview
    @survey = Survey.find(params[:survey_id])

    # Make sure the user has sent enough invitations.
    if @survey.all_invitations.count < 4 then
      flash[:error] = "You must invite at least 4 organizations"
      redirect_to survey_invitations_path(@survey)
    end

    # Must create a participation object for the participation form to use.
    @participation = Participation.new
  end
    
end
