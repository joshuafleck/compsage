class DiscussionsController < ApplicationController
	before_filter :login_or_invite_required, :setup
	
	def setup
		@survey = Survey.find(params[:survey_id])
	end
	
	def index
	  @page_subject = "Discussions"
    @breadcrumbs << [@survey.job_title, url_for(survey_path(@survey))] 
       
	  @discussions = @survey.discussions.roots
	  
		respond_to do |wants|
      wants.html
      wants.xml do
      	render :xml => @discussions.to_xml 
      end
    end
  end
  
  def new
    @page_subject = "New Discussion"
    @breadcrumbs << [@survey.job_title, url_for(survey_path(@survey))] 
    
    @discussion = Discussion.new
    
    if !params[:parent_discussion_id].blank? then
      @parent_discussion = @survey.discussions.find(params[:parent_discussion_id])
    end
    
  end

  def create
    #Note that create must be called rather then new-> save to ensure the parent/child relationships are created
    @discussion = current_organization_or_invitation.discussions.create!(params[:discussion])
    
    respond_to do |wants|
      wants.html {         
        flash[:notice] = "Your discussion was created successfully."
        redirect_to survey_discussions_path(@survey) }      
      wants.xml do
        render :status => :created
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |wants|
      wants.html do
        render :action => 'new'
      end
      wants.xml do
        render :xml => @discussion.errors.to_xml, :status => 422
      end
    end
  end
  
  def edit
    @discussion = current_organization_or_invitation.discussions.find(params[:id])
    
    @page_subject = "Editing #{@discussion.topic}"
    @breadcrumbs << [@survey.job_title, url_for(survey_path(@survey))] 
  end
  
  def update
    @discussion = current_organization_or_invitation.discussions.find(params[:id])  
    
    @discussion.update_attributes!(params[:discussion])
    
    respond_to do |wants|
      wants.html do
        flash[:notice] = "Your discussion was updated successfully."
        redirect_to survey_discussions_path(@survey)
      end
      wants.xml do
        render :status => :ok
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |wants|
      wants.html do
        render :action => 'edit'
      end
      wants.xml do
        render :xml => @discussion.errors.to_xml, :status => 422
      end
    end
  end
  
  def report
    @discussion = @survey.discussions.find(params[:id])
    
    @discussion.increment!(:times_reported)
    
    respond_to do |wants|
      wants.html {         
        flash[:notice] = "The discussion was reported successfully."
        redirect_to survey_discussions_path(@survey) }      
      wants.xml do
        render :status => :ok
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |wants|
      wants.html do
        flash[:notice] = "Unable to report discussion at this time. Please try again later."
        redirect_to survey_discussions_path(@survey)
      end
      wants.xml do
        render :xml => @discussion.errors.to_xml, :status => 422
      end
    end
  end
  
  def destroy
    @discussion = current_organization_or_invitation.discussions.find(params[:id])

    @discussion.destroy
    
    respond_to do |wants|
      wants.html {         
        flash[:notice] = "The discussion was deleted successfully."
        redirect_to survey_discussions_path(@survey) }      
      wants.xml do
        render :status => :ok
      end
    end
  end
  
end
