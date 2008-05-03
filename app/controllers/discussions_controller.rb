class DiscussionsController < ApplicationController
	before_filter :login_required, :setup
	
	def setup
		@survey = Survey.find(params[:survey_id])
	end
	
	def index
	  @discussions = @survey.discussions
	  
		respond_to do |wants|
      wants.html
      wants.xml do
      	render :xml => @discussions.to_xml 
      end
    end
  end
  
  def new
  end

  def create
    params[:organization_id => current_organization.id]
    #TODO: populate for an invitation discussion-owner
    @discussion = Discussion.new(params)
    @discussion.save
    respond_to do |wants|
      if @discussion.errors.empty?
        flash[:notice] = "Discussion was created successfully!"
        wants.html { redirect_to survey_discussions_path(@survey) }
      else
        wants.html { render :action => "new" }
      end
    end
  end
  
  def edit
    @discussion = @survey.discussions.find(params[:id])
    #TODO: look for an invitation discussion-owner
    raise "You do not have the rights to access this page." unless @discussion.responder == current_organization
  end
  
  def update
    @discussion = @survey.discussions.find(params[:id])  
    #TODO: look for an invitation discussion-owner
    raise "You do not have the rights to access this page." unless @discussion.responder == current_organization
    respond_to do |wants|
      if @discussion.update_attributes(params)
        flash[:notice] = 'Discussion was successfully updated.'
        wants.html{
          redirect_to survey_discussions_path(@survey) 
        }
      else
        wants.html{ 
          render :action => "edit"
        }
       end
    end
  end
  
  def report
    @discussion = @survey.discussions.find(params[:id])
    #@discussion.times_reported += 1
    @discussion.increment(:times_reported)
    respond_to do |wants|
      if @discussion.errors.empty?
        flash[:notice] = 'Discussion was successfully reported.'        
      else
        flash[:notice] = 'Unable to report discussion. Please try again later.'
      end
      wants.html{
          redirect_to survey_discussions_path(@survey) 
        }
    end
  end
  
  def destroy
    @discussion = @survey.discussions.find(params[:id])
    #TODO: look for an invitation discussion-owner
    raise "You do not have the rights to access this page." unless @discussion.responder == current_organization
    @discussion.destroy
    respond_to do |wants|
      if @discussion.errors.empty?
        flash[:notice] = 'Discussion was successfully deleted.'        
      else
        flash[:notice] = 'Unable to delete discussion. Please try again later.'
      end
      wants.html{
          redirect_to survey_discussions_path(@survey) 
        }
    end
  end
  
end
