class DiscussionsController < ApplicationController
  before_filter :login_or_survey_invitation_required, :find_survey
  layout 'logged_in'

  def create
    @discussion = current_organization_or_survey_invitation.discussions.new(params[:discussion])
    @discussion.survey = @survey

    if !@discussion.save then
      flash[:discussion] = @discussion
    end

    redirect_to survey_path(@survey) 
  end
  
  def update
    @discussion = current_organization_or_survey_invitation.discussions.find(params[:id])  
    @discussion.attributes = params[:discussion] 

    if @discussion.save then
      respond_to do |wants|
        wants.js do
          render :layout => false, :inline => params[:discussion][:body].blank? ? "<%= @discussion.subject %>" : "<%= link_and_format(@discussion.body) %>" 
        end
      end
    else
      respond_to do |wants|
        wants.js do
          render :text => @discussion.errors.full_messages.join(" &amp; ")
        end
      end
    end
  end
  
  # Report a discussion item as inappropriate. Increments the report count of the specified item.
  def report
    @discussion = @survey.discussions.find(params[:id])
    
    if @discussion.increment!(:times_reported) then    
      flash[:notice] = "The discussion was reported"
      redirect_to survey_path(@survey)    
    else
      redirect_to survey_path(@survey)
    end
  end
  
  private
  
  def find_survey
    @survey = Survey.find(params[:survey_id])
  end
end
