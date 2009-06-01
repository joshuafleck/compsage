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
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])

    # Make sure the user has sent enough invitations.
    if @survey.internal_and_external_invitations.count < 4 then
      flash[:error] = "You must invite at least 4 organizations"
      redirect_to survey_invitations_path(@survey)
    end

    # Must create a participation object for the participation form to use.
    @participation = Participation.new
  end
  
  def create
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @predefined_question_id = params[:predefined_question_id]
    
    if @predefined_question_id.blank? then # creating a custom question
    
      @question = @survey.questions.new(params[:question])
      
      if @question.save then
        respond_to do |wants|
          wants.js do
            render(:partial => "question", :object => @question).to_json
          end
        end
      end
      
    else # creating a predefined question (could result in multiple questions
    
      @questions = PredefinedQuestion.find(@predefined_question_id).build_questions(@survey)
      
      respond_to do |wants|
        wants.js do
          render(:partial => "question", :collection => @questions).to_json
        end
      end      
    
    end
  
  end
  
  def update
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @question = @survey.questions.find(params[:id])    
    
    if @question.update_attributes(params[:question]) then
      respond_to do |wants|
        wants.js do
          render(:partial => "question", :object => @question).to_json
        end
      end
    end
    
  end  
  
  def destroy
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @question = @survey.questions.find(params[:id])
    
    @question.destroy
    
    respond_to do |wants|
      wants.xml do
        head :status => :ok
      end
    end
  end
  
  # changes the order of the question
  def move
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @question = @survey.questions.find(params[:id])
    @direction = params[:direction]
    
    if (@direction == 'lower') then
      @question.move_lower
    elsif (@direction == 'higher') then
      @question.move_higher
    end
    
    respond_to do |wants|
      wants.xml do
        head :status => :ok
      end
    end
  end
    
end
