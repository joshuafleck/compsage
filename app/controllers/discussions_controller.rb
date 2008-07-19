class DiscussionsController < ApplicationController
	before_filter :login_or_survey_invitation_required, :setup
	layout 'logged_in'
  
	def setup
		@survey = Survey.find(params[:survey_id])
	end
	
	def index
       
	  @discussions = @survey.discussions.within_abuse_threshold.roots
	  
		respond_to do |wants|
      wants.html
      wants.xml do
      	render :xml => @discussions.to_xml 
      end
    end
  end
  
  def new
    
    #Create a new disussion and set its survey
    @discussion = Discussion.new
    @discussion.survey = @survey
    
    #If this is a reply, there will be a parent discussion. 
    #This will set the parent discussion id in the new discussion,
    #and also prepopulate the subject field.
    if !params[:parent_discussion_id].blank? then
      @parent_discussion = @survey.discussions.find(params[:parent_discussion_id])
      @discussion.parent_discussion_id = @parent_discussion.id
      @discussion.subject = "RE: " + @parent_discussion.subject
    end
    
  end

  def create
    @discussion = current_organization_or_survey_invitation.discussions.new(params[:discussion])
    
    if @discussion.save then
      respond_to do |wants|
        wants.html {         
          flash[:notice] = "Your discussion was created successfully."
          redirect_to survey_path(@survey) }      
        wants.xml do
          render :status => :created
        end
      end
    else
      respond_to do |wants|
        wants.html do
          render :action => 'new'
        end
        wants.xml do
          render :xml => @discussion.errors.to_xml, :status => 422
        end
      end
    end
  end
  
  def edit
    @discussion = current_organization_or_survey_invitation.discussions.find(params[:id])
    
    @page_title = "Editing #{@discussion.subject}"
    @breadcrumbs << [@survey.job_title, url_for(survey_path(@survey))] 
  end
  
  def update
    @discussion = current_organization_or_survey_invitation.discussions.find(params[:id])  
    
    if @discussion.update_attributes(params[:discussion]) then    
      respond_to do |wants|
        wants.html do
          flash[:notice] = "Your discussion was updated successfully."
          redirect_to survey_path(@survey)
        end
        wants.xml do
          render :status => :ok
        end
      end
    else
      respond_to do |wants|
        wants.html do
          render :action => 'edit'
        end
        wants.xml do
          render :xml => @discussion.errors.to_xml, :status => 422
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
          render :status => :ok
        end
      end
    else
      respond_to do |wants|
        wants.html do
          render :action => 'index'
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
        flash[:notice] = "The discussion was deleted successfully."
        redirect_to survey_path(@survey) }      
      wants.xml do
        render :status => :ok
      end
    end
  end
  
end
