class SurveysController < ApplicationController
  #we require a valid login if you are creating or editing a survey.
  before_filter :login_required, :only => [ :edit, :update, :create, :new, :index ]
  before_filter :login_or_survey_invitation_required, :except => [ :edit, :update, :create, :new, :index ]
  
  def index    
    respond_to do |wants|
      wants.html {
        @running_surveys = current_organization.surveys.open.find(:all, :order => 'created_at DESC')
        @invited_surveys = current_organization.survey_invitations.find(:all, :include => :surveys)
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
    @predefined_questions.collect! { |q| q.chosen = @picked_questions.any? { |pq| pq.text = q.text } }
  end
  
  def update
    @survey = current_organization.surveys.open.find(params[:id])
    @predefined_questions = PredefinedQuestion.all
    @predefined_questions.each do |predefined_question|
      #if selected, create if not found
      if params[:predefined_question][predefined_question.position][:selected]
       #find_or_create_by_text will only create new.
      #find and delete
      else
        #find question
        #destroy if found!!
      end
    end
    respond_to do |wants|
       if @survey.update_attributes(params[:survey])
         flash[:notice] = 'Survey was successfully updated.'
         wants.html{
           redirect_to survey_path(@survey) 
           }
       else
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
    
    #iterate through predefined questions and add to survey
    @predefined_questions.each do |predefined_question|
      if params[:predefined_question][predefined_question.position][:selected]
        @survey.questions.create(:position => predefined_question.position,
                              :text => predefined_question.text,
                              :question_type => predefined_question.question_type,
                              :question_parameters => predefined_question.question_parameters,
                              :html_parameters => predefined_question.html_parameters,
                              :options => predefined_question.options)
      end
    end
    
    @survey.save
    #render a response
    respond_to do |wants|
      if @survey.errors.empty?
        flash[:notice] = "Survey was created successfully!"
        wants.html { redirect_to invitation_path(@survey) }
      else
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
      @response.update_attributes(params[:question][question.id][:response])
      #if it is invalid, add to responses hash
      @responses[question.id] = @response unless @response.save
    end
    
    #if there were no invalid responses, redirect to the survey show page
    respond_to do |wants|
      wants.html{
        if @responses.empty?
          flash[:notice] = "Survey was successfully completed!"
          #current user is an organization, redirect to the show page
          if current_organization_or_survey_invitation.is_a?(Organization)
            redirect_to survey_path(@survey)
          #invite based user, redirect to sign-up page   
          else
            redirect_to signup_path
          end
        #else send back to the questions index
        else
          flash[:notice] = "Please review and re-submit your responses."
          redirect_to survey_questions_path(@survey, @responses)
        end
      }
    end
  end
  
end
