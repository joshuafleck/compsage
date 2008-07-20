class SurveysController < ApplicationController
  layout 'logged_in'
  #we require a valid login if you are creating or editing a survey.
  before_filter :login_required, :only => [ :edit, :update, :create, :new, :index ]
  before_filter :login_or_survey_invitation_required, :except => [ :edit, :update, :create, :new, :index ]
  
  def index    
    @surveys = Survey.running
    
    respond_to do |wants|
      wants.html {
        @invited_surveys = current_organization.survey_invitations.find(:all, :include => :survey)
      }
      wants.xml {
        render :xml => @surveys.to_xml
      }
    end
  end

  def show
    @survey = Survey.find(params[:id])   
	  @discussions = @survey.discussions.within_abuse_threshold.roots
	  
    respond_to do |wants|
      wants.html {        
        if @survey.closed? == :true
          redirect_to survey_report_path(@survey)
        end
        #Show a different layout if the user is replying with an external survey invitation
        render :layout => 'survey_invitation_logged_in' if invited_to_survey?
      }
      wants.xml{
          render :xml => @survey.to_xml
      }
    end
  end

  def edit

    @survey = current_organization.surveys.running.find(params[:id])

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
    @survey = current_organization.surveys.running.find(params[:id])
    
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
  end
  
  def create
    @survey = current_organization.surveys.new(params[:survey])
    @predefined_questions = PredefinedQuestion.all
    
    #iterate through predefined questions and each group
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
    
    if @survey.save
      respond_to do |wants|
        flash[:notice] = "Survey was created successfully!"
        wants.html { redirect_to survey_invitations_path(@survey) }
      end
    else
      respond_to do |wants|
        wants.html { render :action => "new" }
      end
    end
  end

  def search
    
    @search = Ultrasphinx::Search.new(:query => params[:search_text])
    @search.run
    @surveys = @search.results
    
    respond_to do |wants|
      wants.html {}
      wants.xml {render :xml => @surveys.to_xml}
    end
  end
  
  def respond
    @responses = []
    @survey = Survey.find(params[:id])
    @participation = current_organization_or_survey_invitation.participations.find_or_create_by_survey_id(@survey)
    
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
          wants.html{ redirect_to signup_path }
        end
      end
    end
  end
  
  #These are the surveys the user has sponsored or responded to
  def my   
    
    @surveys = current_organization.my_surveys
    
    respond_to do |wants|
      wants.html {}
      wants.xml {
        render :xml => @surveys.to_xml
      }
    end
  end  
  
end
