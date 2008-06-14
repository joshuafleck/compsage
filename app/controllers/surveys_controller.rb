class SurveysController < ApplicationController
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
  end
  
  def update
    @survey = current_organization.surveys.open.find(params[:id])
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
    
  end
  
  def create
    @survey = Survey.create(params[:survey])
    respond_to do |wants|
      if @survey.errors.empty?
        flash[:notice] = "Survey was created successfully!"
        wants.html { redirect_to invitation_url(@survey) }
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
    @survey = params[:survey]
    #validate all responses required for the survey  
    @survey.questions.each do |question|
      @response = current_organization_or_invitation.responses.find_or_create_by_question_id(question.id)
      @response.update_attributes(params[:question][question.id][:response])
      #if it is invalid, add to responses hash
      @responses[question.id] = @response unless @response.save
    end
    #if there were no invalid responses, redirect to the survey show page
    if @responses.empty?
      redirect_to survey_path(@survey) 
    #else send back to the questions index
    else
      redirect_to survey_questions_path(@survey, @responses)
    end
  end
  
end
