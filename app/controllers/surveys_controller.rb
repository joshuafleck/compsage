class SurveysController < ApplicationController
  layout :logged_in_or_invited_layout 
  # we require a valid login if you are creating or editing a survey.
  before_filter :login_required, :only => [ :edit, :update, :create, :new, :index ]
  before_filter :login_or_survey_invitation_required, :except => [ :edit, :update, :create, :new, :index ]
  
  
  def index    
    
    respond_to do |wants|
      wants.html {
        @surveys = Survey.running.paginate(:page => params[:page], :order => 'job_title')  
        @invited_surveys = current_organization.survey_invitations.pending.running.find(:all,:order => 'invitations.created_at desc')
        @my_surveys = current_organization.sponsored_surveys.not_finished.find(:all, :order => 'end_date DESC');
        @participated_surveys = current_organization.participated_surveys.find(:all, :order => 'end_date DESC',
                                                                              :conditions => ['sponsor_id <> ?', current_organization.id]);
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

    build_question_edit
    
  end
  
  def update
    @survey = current_organization.sponsored_surveys.running.find(params[:id])
        
    #update custom question selection, add any new custom questions
    params[:question].each do |id,question|
      question_exists = @survey.questions.exists?(question[:id])
      if question[:included] == "1" && !question_exists then
        @question = @survey.questions.new(question)
        @question[:survey_id] = @survey.id
        @question.save! 
      elsif question[:included] == "0" && question_exists
        @survey.questions.find_by_id(id).destroy
      end
    end unless params[:question].blank?
         
    #update predefined question selection
    @predefined_questions = PredefinedQuestion.all
    @predefined_questions.each do |predefined_question_group|
      #if selected, create if not found
      if params[:predefined_question][predefined_question_group.id.to_s][:included] == "1"
         #iterate through each pdq group and create the questions
         predefined_question_group.question_hash.each do |predefined_question|
           #find or create the question
           @question = @survey.questions.find_or_create_by_text(predefined_question[:text])
           #assign the attributes
           @question.attributes = predefined_question.except("id", :id)
           @question.predefined_question_id = predefined_question_group.id
           @question.save!
         end
      #destroy if the question was previously selected.
      else
        predefined_question_group.question_hash.each do |predefined_question|
          @question = @survey.questions.find_by_text(predefined_question[:text])
          @question.destroy unless @question.nil?
        end
      end
    end
    
    #update the attributes for the survey
    if @survey.update_attributes(params[:survey])
       respond_to do |wants|  
         flash[:notice] = 'Survey updated.'
         wants.html{
           redirect_to survey_path(@survey) 
           }
       end
     else
       respond_to do |wants|
         wants.html{ 
           build_question_edit
           render :action => :edit
         }
       end
     end
  end
  
  def new
    @predefined_questions = PredefinedQuestion.all
    @questions = {}
    @survey = Survey.new

    # Check to see if we arrived here from a 'survey network' link. If so, send the network along.
    if !params[:network_id].blank? then
      @network = current_organization.networks.find(params[:network_id])
    end
  end
  
  def create
    @survey = current_organization.sponsored_surveys.new(params[:survey])
    @predefined_questions = PredefinedQuestion.all
    @questions = {}
    
    has_questions = !params[:question].blank?
    
    #Create actual questions here in case the survey validation fails,
    # the view needs question models in order to create the question form.
    params[:question].each do |id,question|
      @questions[id] = @survey.questions.new(question)
    end unless params[:question].blank?
      
    #Set the 'included' flag to 1 in case the survey validation fails,
    # this will ensure any selections are preserved.
    @predefined_questions.each do |predefined_question_group|
      predefined_question_group.included = params[:predefined_question][predefined_question_group.id.to_s][:included]
      has_questions = true if predefined_question_group.included == "1"
    end unless params[:predefined_question].blank?      
    
    if has_questions && @survey.save
    
      # iterate through only the selected predefined questions to save
      @predefined_questions.each do |predefined_question_group|
        if predefined_question_group.included == "1" then
          predefined_question_group.question_hash.each do |predefined_question|
            @question = @survey.questions.new(predefined_question.except("id", :id))
            @question.predefined_question_id = predefined_question_group.id
            @question.save!
          end
        end
      end 
      
      # iterate through only the selected custom questions to save
      @questions.values.each do |question|
        if question.included == "1" then
          question[:survey_id] = @survey.id
          question.save!
        end
      end 
      
      # For now, pretend we've received billing information.
      @survey.billing_info_received!
      
      respond_to do |wants|
        wants.html do

          #Check to see if the user created the survey from a 'survey network' link. If so, create the invitation.
          if params[:invite_network].blank? then
            redirect_to survey_invitations_path(@survey)
          else
            redirect_to create_with_network_survey_invitations_path(@survey, :invitation => 
            {
              :network_id => params[:invite_network]
            })
          end
        end
      end
      
    else
      respond_to do |wants|
        flash[:notice] = "A survey must have at least one question" unless has_questions
        wants.html { render :action => "new" }
      end
    end
  end

  def search
    #TODO: highlight search text in survey description (if applicable)
  
    @search_text = params[:search_text]
    
    @search_query = "#{@search_text} #{@search_text} | @industry \"#{current_organization.industry}\""      
    
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
        @running_surveys = current_organization.surveys.running.paginate(:page => params[:page], :order => 'job_title')
        @finished_surveys = current_organization.surveys
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
  
  def build_question_edit

    #iterate through the survey questions to determine which predefined questions have been selected
    @predefined_questions = PredefinedQuestion.all
    @picked_questions = @survey.questions
    
    #check which pdqs are to be included on the edit form
    @predefined_questions.each do |q| 
      q.included = @picked_questions.any? do |pq| 
        pq.predefined_question_id == q.id
      end
    end
        
    @questions = {}
    
    #Find any custom questions and make sure they have the 'included' flag populated
    # Build a hash to pass to the view, so that we can intermix new questions and existing questions
    @picked_questions.each do |question|
      if !question.custom_question_type.blank? then
        question.included = "1"
        @questions[question.id.to_s] = question
      end
    end  
  
  end

  def logged_in_or_invited_layout
    logged_in? ? "logged_in" : "survey_invitation_logged_in"
  end
end
