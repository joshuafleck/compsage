class SurveysController < ApplicationController
  layout :logged_in_or_invited_layout 

  before_filter :login_required, :except => [:show, :respond]
  before_filter :login_or_survey_invitation_required, :only => [:show, :respond]

 
  ssl_required :respond
  
  def index    
    @surveys = Survey.with_aasm_state(:running).paginate(:page => params[:page], :order => 'job_title')  
    @invited_surveys = current_organization.survey_invitations.sent.running.ordered_by('invitations.created_at DESC')
    @my_surveys = current_organization.sponsored_surveys.with_aasm_states(:running, :stalled).find(:all, :order => 'end_date DESC');
    @survey_participations = current_organization.participations.recent.not_sponsored_by(current_organization)
    @my_results = current_organization.surveys.with_aasm_state(:finished).recent
  end

  def show
    @survey = Survey.find(params[:id], :include => [:invitations, :external_invitations])  
    @invitations = @survey.internal_and_external_invitations.not_pending.sort
    @discussions = @survey.discussions.within_abuse_threshold.roots
    @discussion = flash[:discussion] || @survey.discussions.new
    @participation = current_organization_or_survey_invitation.participations.find_by_survey_id(@survey)
	  
    if @survey.finished?
      redirect_to survey_report_path(@survey)
    else
      render :action => "show_#{@survey.aasm_state}"
    end
  end

  def edit
    @survey = current_organization.sponsored_surveys.with_aasm_states(:running, :pending).find(params[:id])

    if @survey.participations.any? then # Can't make changes if there are participations.
      flash[:notice] = "You cannot edit the questions for a survey once a response has been collected."
      redirect_to survey_path(@survey)
    end
  end
  
  def update
    @survey = current_organization.sponsored_surveys.with_aasm_states(:running, :pending).find(params[:id])

    if @survey.participations.any? then  # Can't make changes if there are participations.
      flash[:notice] = "You cannot edit the questions for a survey once a response has been collected."
      redirect_to survey_path(@survey)
    else
      @survey.attributes = params[:survey]
      @survey.association = current_association
      if @survey.save
        if @survey.running? then         # Editing a running survey
          redirect_to preview_survey_questions_path(@survey)
        else                             # Pending, likely on survey creation path
          redirect_to survey_invitations_path(@survey)
        end
      else
        render :action => :edit
      end
    end
  end
  
  def new
    @survey = current_organization.sponsored_surveys.find_or_create_by_aasm_state('pending')
    # If we came from a 'survey network' link, save the network in the session to be accessed later when sending
    # invitations
    session[:survey_network_id] = params[:network_id] unless params[:network_id].blank?
  end

  # Search running surveys.
  # TODO: Hightlight search text in survey description (if applicable) - see TS 'Excerpts' feature
  def search
    @search_text = params[:search_text] || ""
    
    escaped_search_text = Riddle.escape(@search_text)
      
    @surveys = Survey.search escaped_search_text,
      :geo => [current_organization.latitude, current_organization.longitude],
      :order => '@weight desc, @geodist asc' # Sort by relevance, then distance
  end
  
  # Respond to a survey. Creates the participatoin object for either the organization or invitation responding.
  def respond
    @survey = Survey.find(params[:id])
    @participation = current_organization_or_survey_invitation.participations.find_or_initialize_by_survey_id(@survey.id)
    @participation.attributes = params[:participation]

    if @participation.save then
      flash[:notice] = "Thank you for participating in the survey!  You will be notified when results are available."
      
      if current_organization_or_survey_invitation.is_a?(Organization) then
        redirect_to survey_path(@survey)    # Is a member, redirect to survey show page.
      else
        redirect_to new_account_path        # Came via invite, so give them a chance to sign up.
      end
    else
      render :template => 'questions/index' # Render the participation form.
    end
  end
  
  # All the data the user has
  def reports
    @surveys = current_organization.surveys.with_aasm_state(:finished).paginate(:page => params[:page])
  end
  
  # Allows users to re-run a stalled survey
  def rerun
    @survey = current_organization.sponsored_surveys.with_aasm_state(:stalled).find(params[:id])

    # Set the new end date, attempt to reset the state of the survey
    if @survey.update_attributes(params[:survey]) && @survey.rerun then
      redirect_to survey_invitations_path(@survey) 
    else
      flash[:notice] = 'Unable to rerun survey. Please choose an end date in the future.'
      redirect_to survey_path(@survey)
    end
  end
  
  # Allows users to view the results of a partial report
  def finish_partial
    @survey = current_organization.sponsored_surveys.with_aasm_state(:stalled).find(params[:id])
    @survey.finish_with_partial_report! # Raise an exception if we cannot finish the report for some reason.

    redirect_to survey_report_path(@survey) 
  end
      
  def destroy
    @survey = current_organization.sponsored_surveys.with_aasm_states(:pending,:stalled).find(params[:id])
    @survey.destroy
    
    redirect_to surveys_path
  end  
end
