class SurveysController < ApplicationController
  layout :logged_in_or_invited_layout 
  #we require a valid login if you are creating or editing a survey.
  before_filter :login_required, :only => [ :edit, :update, :create, :new, :index ]
  before_filter :login_or_survey_invitation_required, :except => [ :edit, :update, :create, :new, :index ]
  
  
  def index    
    @surveys = Survey.running
    
    respond_to do |wants|
      wants.html {
        @invited_surveys = current_organization.survey_invitations.running
      }
      wants.xml {
        render :xml => @surveys.to_xml
      }
    end
  end

  def show
    @survey = Survey.find(params[:id], :include => [:invitations, :external_invitations])   
	  @discussions = @survey.discussions.within_abuse_threshold.roots
	  
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

    #iterate through the survey questions to determine which predefined questions have been selected
    @predefined_questions = PredefinedQuestion.all
    @picked_questions = @survey.questions
    
    #check which pdqs are to be included on the edit form
    @predefined_questions.each do |q| 
      q.included = @picked_questions.any? do |pq| 
        pq.predefined_question_id == q.id
      end
    end
  end
  
  def update
    @survey = current_organization.sponsored_surveys.running.find(params[:id])
    
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
           @question.save
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
         flash[:notice] = 'Survey was successfully updated.'
         wants.html{
           redirect_to survey_path(@survey) 
           }
       end
     else
       respond_to do |wants|
         wants.html{ 
           redirect_to edit_survey_path(@survey)
         }
       end
     end
  end
  
  def new
    @predefined_questions = PredefinedQuestion.all

    # Check to see if we arrived here from a 'survey network' link. If so, send the network along.
    if !params[:network_id].blank? then
      @network = current_organization.networks.find(params[:network_id])
    end
  end
  
  def create
    @survey = current_organization.sponsored_surveys.new(params[:survey])
    @predefined_questions = PredefinedQuestion.all
    
    if @survey.save
      # iterate through predefined questions and each group
      @predefined_questions.each do |predefined_question_group|
        @predefined_question_hash = predefined_question_group.question_hash
        if params[:predefined_question][predefined_question_group.id.to_s][:included] == "1"
          @predefined_question_hash.each do |predefined_question|
            @question = @survey.questions.new(predefined_question.except("id", :id))
            @question.predefined_question_id = predefined_question_group.id
            @question.survey = @survey
            @question.save
          end
        end
      end
      
      respond_to do |wants|
        flash[:notice] = "Survey was created successfully!"
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
        wants.html { render :action => "new" }
      end
    end
  end

  def search
  
    if params[:search_subscribed_only].blank? then
      @surveys = Survey.search(params[:search_text])
    else
      @surveys = Survey.search(params[:search_text], :conditions => {:subscribed_by => current_organization.id})
    end
    
    respond_to do |wants|
      wants.html {}
      wants.xml {render :xml => @surveys.to_xml}
    end
  end
  
  def respond
    @responses = []
    @survey = Survey.find(params[:id])
    @participation = current_organization_or_survey_invitation.participations.find_or_create_by_survey_id(@survey.id)
    
    #validate all responses required for the survey before saving, need
    @survey.questions.each do |question|
      @response = @participation.responses.find_or_create_by_question_id(question.id)
      
      if question.numerical_response? #TODO: modifiy model code to figure out which of these to set
        @response.numerical_response = params[:responses][question.id.to_s]
      else
        @response.textual_response = params[:responses][question.id.to_s]
      end
      
      #collect all responses, TODO: ignore non-required responses, not avail until phase 2
      @responses << @response
    end

    #if there were no invalid responses, save the results and redirect to the survey show page
    if @responses.any? { |r| !r.valid? }
      flash[:notice] = "Please review and re-submit your responses."
      respond_to do |wants|
        wants.html { redirect_to survey_questions_path(@survey)  }
      end
      #we have all valid responses, proceed!
    else
      @responses.each do |response|
        response.save!
      end
      
      flash[:notice] = "Survey was successfully completed!"
      #current user is an organization, redirect to the show page
      if current_organization_or_survey_invitation.is_a?(Organization)
        respond_to do |wants|
          wants.html{ redirect_to survey_path(@survey) }
        end
      #invite based user, redirect to sign-up page   
      else
        respond_to do |wants|
          wants.html{ redirect_to new_account_path }
        end
      end
    end
  end
  
  #These are the surveys the user has sponsored or responded to
  def my   
    
    @surveys = current_organization.surveys
    
    respond_to do |wants|
      wants.html {}
      wants.xml {
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
         flash[:notice] = 'Survey was successfully updated.'
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
 
    
  private
    def logged_in_or_invited_layout
      logged_in? ? "logged_in" : "survey_invitation_logged_in"
    end
  
end
