class SurveysController < ApplicationController
  layout :logged_in_or_invited_layout 
  # we require a valid login if you are creating or editing a survey.
  before_filter :login_required, :only => [ :edit, :update, :create, :new, :index ]
  before_filter :login_or_survey_invitation_required, :except => [ :edit, :update, :create, :new, :index ]
  
  
  def index    
    
    respond_to do |wants|
      wants.html {
        @surveys = Survey.running.paginate(:page => params[:page], :order => 'job_title')  
        @invited_surveys = current_organization.survey_invitations.pending.running.find(
          :all,
          :order => 'invitations.created_at desc')
        @my_surveys = current_organization.sponsored_surveys.not_finished.find(:all, :order => 'end_date DESC');
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
      wants.html {
        if @survey.finished?
          redirect_to survey_report_path(@survey)
        end
      }
      wants.xml{
          render :xml => @survey.to_xml
      }
    end
  end

  def edit

    @survey = current_organization.sponsored_surveys.running.find(params[:id])
    
  end
  
  def update
    @survey = current_organization.sponsored_surveys.running.find(params[:id])
     
    # find all predefined questions, determine if they already exist
    #  all selected non-existent questions are created
    #  all un-selected existing questions are deleted    
    params[:predefined_questions].each_pair do |predefined_question_id, params|
      existing_questions = @survey.questions.find_all_by_predefined_question_id(predefined_question_id)
      if existing_questions.size == 0 then
        PredefinedQuestion.find(predefined_question_id).build_questions(@survey) if params[:included] == "1"
      else
        existing_questions.each do |q| 
          q.destroy 
        end if params[:included] == "0"
      end    
    end unless params[:predefined_questions].blank?        
       
    # find all custom questions, determine if they already exist
    #  all selected non-existent questions are created
    #  all un-selected existing questions are deleted
    # need to sort questions based on created date to preserve order 
    params[:questions].sort{|a,b| a[0].to_i <=> b[0].to_i}.each do |key,question|
      existing_question = @survey.questions.find_by_id(question[:id]) unless question[:id].blank?
      if existing_question.nil? then
        @survey.questions.build(question).move_to_bottom if question[:included] == "1"
      else
        existing_question.destroy if question[:included] == "0"
      end
    end unless params[:questions].blank?

    #update the attributes for the survey
    if @survey.update_attributes(params[:survey])
       respond_to do |wants|  
         #flash[:notice] = 'Survey updated.'
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
    @survey = Survey.new(:network_id => params[:network_id])
  end
  
  def create
    @survey = current_organization.sponsored_surveys.new(params[:survey])
    
    params[:predefined_questions].each_pair do |predefined_question_id, params|
      PredefinedQuestion.find(predefined_question_id).build_questions(@survey) if params[:included] == "1"
    end unless params[:predefined_questions].blank?
    
    # need to sort questions based on created date to preserve order 
    params[:questions].sort{|a,b| a[0].to_i <=> b[0].to_i}.each do |key,question|
      @survey.questions.build(question).move_to_bottom if question[:included] == "1"
    end unless params[:questions].blank?

    if @survey.save
    
      # For now, pretend we've received billing information.
      @survey.billing_info_received!
      
      # invite the network, if this came from the 'survey network' link
      @survey.invite_network
      
      respond_to do |wants|
        wants.html do
          redirect_to preview_survey_questions_path(@survey)
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
  
    @search_text = params[:search_text]
    
    @esc_search_text = Riddle.escape(@search_text)
    
    @search_query = "#{@esc_search_text} #{@esc_search_text} | @industry \"#{current_organization.industry}\""      
    
    @filter_by_subscription = params[:filter_by_subscription]
    
    @search_params = {
      :geo => [current_organization.latitude, current_organization.longitude],
      :conditions => {},
      :with => {},
      :match_mode => :extended, # this allows us to use boolean operators in the search query
      :order => '@weight desc, @geodist asc' # sort by relevance, then distance
    }
    
    # filters by subscription (my surveys)
    @search_params[:conditions][:subscribed_by] = current_organization.id unless @filter_by_subscription.blank?
    @search_params[:conditions][:aasm_state_number] = Survey::AASM_STATE_NUMBER_MAP['running'] if @filter_by_subscription.blank?
    
    @surveys = Survey.search @search_query, @search_params
       
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
  
  def destroy
    @survey = current_organization.sponsored_surveys.stalled.find(params[:id])

    @survey.destroy
    
    respond_to do |wants|
      wants.html {         
        redirect_to surveys_path() }      
      wants.xml do
        render :status => :ok
      end
    end
  end  
 
    
  private
  
  def logged_in_or_invited_layout
    logged_in? ? "logged_in" : "survey_invitation_logged_in"
  end
end
