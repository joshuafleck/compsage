  class SurveysController < ApplicationController
  layout :logged_in_or_invited_layout 
  # we require a valid login if you are creating or editing a survey.
  before_filter :login_required, :only => [ :edit, :update, :create, :new, :index, :destroy, :billing ]
  before_filter :login_or_survey_invitation_required, :except => [ :edit, :update, :create, :new, :index ]
  filter_parameter_logging :response  
 
  ssl_required :respond
  
  def index    
    
    respond_to do |wants|
      wants.html {
        @surveys = Survey.running.paginate(:page => params[:page], :order => 'job_title')  
        @invited_surveys = current_organization.survey_invitations.sent.running.find(
          :all,
          :order => 'invitations.created_at desc')
        @my_surveys = current_organization.sponsored_surveys.running_or_stalled.find(:all, :order => 'end_date DESC');
        # Include surveys that are running and those that are stalled within the last day
        @survey_participations = current_organization.participations.find(:all,
          :include => :survey,
          :order => 'surveys.end_date DESC',
          :conditions => ['surveys.sponsor_id <> ? AND (surveys.aasm_state = ? OR (surveys.aasm_state = ? AND surveys.end_date > ?))',
            current_organization.id,
            'running',
            'stalled',
            Time.now - 1.day]);

        @my_results = current_organization.surveys.finished.recent
      }
      wants.xml {
        @surveys = Survey.running
        render :xml => @surveys.to_xml
      }
    end
  end

  def show
    @survey = Survey.find(params[:id], :include => [:invitations, :external_invitations])  
    @invitations = @survey.all_invitations(true) 
    @discussions = @survey.discussions.within_abuse_threshold.roots
    @discussion = @survey.discussions.new
    @participation = current_organization_or_survey_invitation.participations.find_by_survey_id(@survey)
	  
    respond_to do |wants|
      wants.html do
        if @survey.finished?
          redirect_to survey_report_path(@survey)
        else
          render :action => "show_#{@survey.aasm_state}"
        end
      end
      wants.xml do
        render :xml => @survey.to_xml
      end
    end
  end

  def edit
    @survey = current_organization.sponsored_surveys.running_or_pending.find(params[:id])
  end
  
  def update
    @survey = current_organization.sponsored_surveys.running_or_pending.find(params[:id])
     
    #update the attributes for the survey
    if @survey.update_attributes(params[:survey])
       respond_to do |wants|  
         wants.html{
           redirect_to preview_survey_questions_path(@survey) 
           }
       end
     else
       respond_to do |wants|
         wants.html{ 
           render :action => :edit
         }
       end
     end
  end
  
  def new
    @survey = current_organization.sponsored_surveys.find_or_initialize_by_aasm_state('pending') 
    
    # if we came from a 'survey network' link, save the network in the session to be accessed later when sending
    # invitations
    session[:survey_network_id] = params[:network_id] unless params[:network_id].blank?
  end
  
  def create
    @survey = current_organization.sponsored_surveys.find_or_create_by_aasm_state('pending')
    
    if @survey.update_attributes(params[:survey])
                
      respond_to do |wants|
        wants.html do
          redirect_to survey_invitations_path(@survey)
        end
      end
      
    else
      respond_to do |wants|
        wants.html { render :action => "new" }
      end
    end
  end

  def search
    #TODO: highlight search text in survey description (if applicable)
  
    @search_text = params[:search_text] || ""
    
    escaped_search_text = Riddle.escape(@search_text)
      
    # TODO: Why is the search text duplicated? JDF - because it allows us to weight results by industry
    search_query = "#{escaped_search_text} #{escaped_search_text} | @industry \"#{current_organization.industry}\""

    search_params = {
      :geo => [current_organization.latitude, current_organization.longitude],
      :conditions => {},
      :match_mode => :extended, # this allows us to use boolean operators in the search query
      :order => '@weight desc, @geodist asc' # sort by relevance, then distance
    }
    
    # filters by subscription (my surveys)
    search_params[:conditions][:subscribed_by] = current_organization.id unless params[:filter_by_subscription].blank?
    search_params[:conditions][:aasm_state_number] = Survey::AASM_STATE_NUMBER_MAP['running'] if params[:filter_by_subscription].blank?
    
    @surveys = Survey.search search_query, search_params
       
    respond_to do |wants|
      wants.html {}
      wants.xml {render :xml => @surveys.to_xml}
    end
  end
  
  def respond
    @survey = Survey.find(params[:id])
    @participation = current_organization_or_survey_invitation.participations.find_or_initialize_by_survey_id(@survey.id)
    @participation.attributes = params[:participation]
    
    if @participation.save then
      flash[:notice] = "Thank you for participating in the survey!  You will be notified when results are available."
      
      respond_to do |wants|
        wants.html do
          if current_organization_or_survey_invitation.is_a?(Organization) then
            redirect_to survey_path(@survey) # is a member
          else
            redirect_to new_account_path # came via invite, so give them a chance to sign up
          end
        end
      end
    else
      respond_to do |wants|
        wants.html do 
          render :template => 'questions/index' 
        end
      end
    end
  end
  
  # All the data the user has
  def reports
  
    respond_to do |wants|
      wants.html {
        @filter_by_subscription = "true" # need this flag to designate any searches should be against subscribed surveys
        @surveys = current_organization.surveys.finished.paginate(:page => params[:page])
      }
      wants.xml {
        @surveys = current_organization.surveys
        render :xml => @surveys.to_xml
      }
    end
  end
  
  #Allows users to re-run a stalled survey
  def rerun
    @survey = current_organization.sponsored_surveys.stalled.find(params[:id])
    
    #Set the new end date, attempt to reset the state of the survey
    if @survey.update_attributes(params[:survey]) && @survey.rerun!
       respond_to do |wants|  
         flash[:notice] = 'Survey updated.'
         wants.html do
           redirect_to survey_invitations_path(@survey) 
         end
       end
     else
       respond_to do |wants|
         flash[:notice] = 'Unable to rerun survey. Please choose an end date in the future.'
         wants.html do
           redirect_to survey_path(@survey)
         end
       end
     end
  end
  
  #Allows users to view the results of a partial report
  def finish_partial
    @survey = current_organization.sponsored_surveys.stalled.find(params[:id])
    
    if @survey.finish_with_partial_report!
       respond_to do |wants|  
         wants.html do
           redirect_to survey_report_path(@survey) 
         end
       end
     else
       respond_to do |wants|
         flash[:notice] = 'Unable to complete survey. Please try again later'
         wants.html do
           redirect_to survey_path(@survey)
         end
       end
     end    
  end
  
  def billing
    @survey = current_organization.sponsored_surveys.pending.find(params[:id])
    
    # For now, pretend we've received billing information.
    if @survey.aasm_state == 'pending'
      @survey.billing_info_received!
      respond_to do |wants|
        wants.html do
          redirect_to survey_path(@survey)
        end
      end
    
    elsif 
      respond_to do |wants|
        wants.html do
          redirect_to survey_path(@survey)
        end
      end
    end
  end
    
  def destroy
    @survey = current_organization.sponsored_surveys.deletable.find(params[:id])

    @survey.destroy
    
    respond_to do |wants|
      wants.html {         
        redirect_to surveys_path() }      
      wants.xml do
        render :status => :ok
      end
    end
  end  
 
end
