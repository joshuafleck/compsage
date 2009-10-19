class QuestionsController < ApplicationController 
  before_filter :login_or_survey_invitation_required
  layout :logged_in_or_invited_layout 

  ssl_required :index

  def index
    @survey = Survey.with_aasm_state(:running).find(params[:survey_id])
    @participation = current_organization_or_survey_invitation.participations.find_or_initialize_by_survey_id(@survey.id)
  end
  
  def preview
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])

    # Make sure the user has sent enough invitations.
    if @survey.pending? && @survey.enough_invitations_to_create? then
      flash[:error] = "You must invite at least #{Survey::REQUIRED_NUMBER_OF_INVITATIONS} organizations"
      redirect_to survey_invitations_path(@survey)
    end

    # Must create a participation object for the participation form to use.
    @participation = Participation.new
  end
  
  def create
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    
    if params[:predefined_question_id].blank? then # creating a custom question
      @question = @survey.questions.new(params[:question])
      
      if @question.save then
        respond_to do |wants|
          wants.js do
            render(:partial => "question", :object => @question, :locals => {:level => @question.level})
          end
        end
      end
      
    else # creating a predefined question (could result in multiple questions created)
      @questions = PredefinedQuestion.find(params[:predefined_question_id]).build_questions(@survey, params[:parent_question_id], params[:required])
      respond_to do |wants|
        wants.js do
          render(:partial => "question", :collection => @questions, :locals => {:level => @questions.first.level})
        end
      end      
    end
  end
  
  def update
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @question = @survey.questions.find(params[:id])    

    @question.update_attributes(params[:question]) 

    # TODO: Do we need to return the entire partial?
    respond_to do |wants|
      wants.js do
        render(:partial => "question", :object => @question, :locals => {:level => @question.level})
      end
      wants.json do
        render :json => @question.to_json
      end
    end
    
  end  
  
  def destroy
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @question = @survey.questions.find(params[:id])
    
    @question.destroy
    
    respond_to do |wants|
      wants.any do
        head :status => :ok
      end
    end
  end
  
  # changes the order of the question
  def move
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @question = @survey.questions.find(params[:id])
    @direction = params[:direction]
    
    if @direction == 'lower' then
      @question.move_lower
    elsif @direction == 'higher' then
      @question.move_higher
    end
    
    respond_to do |wants|
      wants.any do
        head :status => :ok
      end
    end
  end
    
end
