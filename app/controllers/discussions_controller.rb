class DiscussionsController < ApplicationController
	before_filter :login_or_survey_invitation_required, :find_survey
	layout 'logged_in'
	
  def index
    @discussions = @survey.discussions.all
    respond_to do |wants|
      wants.xml do
        render :xml => @discussions.to_xml 
      end
    end
  end
	
	
  def create
    @discussion = current_organization_or_survey_invitation.discussions.new(params[:discussion])
    @discussion.survey = @survey
    
    if @discussion.save then
      respond_to do |wants|
        wants.html do        
          redirect_to survey_path(@survey) 
        end
        wants.xml do
          head :status => :created
        end
      end
    else
      respond_to do |wants|
        wants.html do
          @invitations = @survey.all_invitations(true) 
      	  @discussions = @survey.discussions.within_abuse_threshold.roots
      	  @participation = current_organization_or_survey_invitation.participations.find_by_survey_id(@survey)          
          render :template => "surveys/show"
        end
        wants.xml do
          render :xml => @discussion.errors.to_xml, :status => 422
        end
      end
    end
  end
  
  def update
    @discussion = current_organization_or_survey_invitation.discussions.find(params[:id])  
    
    if @discussion.update_attributes(params[:discussion]) then    
      respond_to do |wants|
        wants.xml do
          head :status => :ok
        end
        wants.js do
          render :text => params[:discussion][:body].blank? ? @discussion.subject : @discussion.body
        end
      end
    else
      respond_to do |wants|
        wants.xml do
          render :xml => @discussion.errors.to_xml, :status => 422
        end
        wants.js do
          render :text => @discussion.errors.full_messages.join(" &amp; ")
        end
      end
    end
  end
  
  def report
    @discussion = @survey.discussions.find(params[:id])
    
    if @discussion.increment!(:times_reported) then    
      respond_to do |wants|
        wants.html {         
          flash[:notice] = "The discussion was reported successfully."
          redirect_to survey_path(@survey) }      
        wants.xml do
          head :status => :ok
        end
      end
    else
      respond_to do |wants|
        wants.html do
          redirect_to survey_path(@survey)
        end
        wants.xml do
          render :xml => @discussion.errors.to_xml, :status => 422
        end
      end
    end
  end
  
  def destroy
    @discussion = current_organization_or_survey_invitation.discussions.find(params[:id])

    @discussion.destroy
    
    respond_to do |wants|
      wants.html {         
        redirect_to survey_path(@survey) }      
      wants.xml do
        head :status => :ok
      end
    end
  end
  
  private
  
  def find_survey
		@survey = Survey.find(params[:survey_id])
	end
end
