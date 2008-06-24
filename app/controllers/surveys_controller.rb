class SurveysController < ApplicationController
  layout 'logged_in'
  #we require a valid login if you are creating or editing a survey.
  before_filter :login_required, :only => [ :edit, :update, :create, :new, :index ]
  before_filter :login_or_survey_invitation_required, :except => [ :edit, :update, :create, :new, :index ]
  
  def index    
    respond_to do |wants|
      wants.html {
        @running_surveys = current_organization.surveys.open.find(:all, :order => 'created_at DESC')
        @invited_surveys = current_organization.survey_invitations.find(:all, :include => :survey)
        @completed_surveys = current_organization.surveys.closed.find(:all, :order => 'created_at DESC')
      }
      wants.xml {
        @surveys = current_organization.surveys.find(:all)
        render :xml => @surveys.to_xml
      }
    end
  end

  def show
    @survey = Survey.find(params[:id])   
	  @discussions = @survey.discussions.roots
	  
    respond_to do |wants|
      wants.html {        
        if @survey.closed? == :true
          redirect_to survey_report_path(@survey)
        end
      }
      wants.xml{
          render :xml => @survey.to_xml
      }
    end
  end

  def edit
    @survey = current_organization.surveys.open.find(params[:id])
    #iterate through the survey questions to determine which predefined questions have been selected
    @predefined_questions = PredefinedQuestion.all
    @picked_questions = @survey.questions
    @predefined_questions.collect! { |q| q.chosen = @picked_questions.any? { |pq| pq.predefined_question_id = q.id } }
  end
  
  def update
    @survey = current_organization.surveys.open.find(params[:id])

    #update predefined question selection
    @predefined_questions = PredefinedQuestion.all
    @predefined_questions.each do |predefined_question|
      #if selected, create if not found
      if params[:predefined_question][predefined_question.id.to_s]
         #find or create the question
         @question = @survey.questions.find_or_create_by_predefined_question_id(predefined_question.id)
         #assign the attributes
         @question.attributes = predefined_question.attributes.except('id', 'description')
         @question.predefined_question_id = predefined_question.id

         @question.save
      #destroy if the question was previously selected.
      else
          @question = @survey.questions.find_by_predefined_question_id(predefined_question.id)
          @question.destroy unless @question.nil?
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
    puts @survey
    puts ">>>>"
  end
  
  def create
    @survey = current_organization.surveys.new(params[:survey])
    @predefined_questions = PredefinedQuestion.all
    
    #iterate through predefined questions and add to survey
    @predefined_questions.each do |predefined_question|
      if params[:predefined_question][predefined_question.id.to_s]
        @question = @survey.questions.new(predefined_question.attributes.except('id', 'description'))
        @question.predefined_question_id = predefined_question.id
        @question.save                      
      end
    end
    
    if @survey.save
      respond_to do |wants|
        flash[:notice] = "Survey was created successfully!"
        wants.html { redirect_to invitation_path(@survey) }
      end
    else
      respond_to do |wants|
        wants.html { render :action => "new" }
      end
    end
  end

  def search
    @surveys = Survey.find_by_contents(params[:search_text])
    
    respond_to do |wants|
      wants.html {}
      wants.xml {render :xml => @surveys.to_xml}
    end
  end
  
  def respond
    @responses = []
    @survey = Survey.find(params[:id])
    #validate all responses required for the survey  
    @survey.questions.each do |question|
      @response = current_organization_or_survey_invitation.responses.find_or_create_by_question_id(question.id)
      @response.update_attributes(params[:question][question.id.to_s][:response])
      #if it is invalid, add to responses hash
      @responses << @response unless @response.save
    end

    #if there were no invalid responses, redirect to the survey show page
    if @responses.empty?
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
    #else send back to the questions index
    else
      flash[:notice] = "Please review and re-submit your responses."
      respond_to do |wants|
        wants.html { render :action => "questions", :responses => @responses }
      end
    end
  end
  
end
