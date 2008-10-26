class ReportsController < ApplicationController
  layout 'logged_in'
  before_filter :login_or_survey_invitation_required, :must_have_responded
  
  def show
    @survey = Survey.find(params[:survey_id])
    @invitations = @survey.all_invitations(true)
    
    define_response_scope
    
  end
  
  # for for flash charts
  def chart
    @question = Question.find(params[:question_id])
    @survey = @question.survey
    
    define_response_scope
  
    respond_to do |wants|
      wants.xml { render(:layout => false) }
    end
  end
  
  protected
  
  def must_have_responded
    if current_organization_or_survey_invitation.participations.find_by_survey_id(params[:survey_id]).nil? then
       render :text => "You must first respond to the survey before getting results.", :status => :unauthorized
      return false
    end
  end
  
  private
  
  #This will look at the current user/invitation to determine whether or not
  # the scope of responses should be limited to responses of invitees
  def define_response_scope
    @participations = @survey.participations
    
    #Find the current organizations participation for the survey
    @current_organization_or_invitation_participation =
      @current_organization_or_survey_invitation.participations.find_by_survey_id(@survey.id)
    
    #Find the number of participations from invited users
    invitee_participations = @participations.belongs_to_invitee
            
    #If the current organization was invited to the survey and 
    # there were more than 5 participations from invited users,     
    # then we will filter out any responses from uninvited participants
    @show_only_invitee_responses = invitee_participations.count >= 5 &&   
      invitee_participations.include?(@current_organization_or_invitation_participation)
    
    #Determine the number of participations based on the scope  
    if @show_only_invitee_responses then
      @total_participation_count = invitee_participations.count
    else
      @total_participation_count = @participations.size
    end    
    
    #Here we determine which methods in the question model will be called to retrieve responses
    if @show_only_invitee_responses then
      @responses_method = 'invitee_responses'
      @grouped_responses_method = 'invitee_grouped_responses'
    else
      @responses_method = 'responses'
      @grouped_responses_method = 'grouped_responses'
    end 
    
  
  end
  
end
