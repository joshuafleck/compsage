class SurveyInvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def index
    @survey = current_organization.surveys.find(params[:survey_id])
    @invitations = @survey.invitations.find(:all, :include => :invitee)
    
    respond_to do |wants|
      wants.html {} # render the template
      wants.xml { render :xml => @invitations.to_xml }
    end
  end
  
  def new
    # render the new template
  end
  
  # Creates the new survey invitation.  If the organization is not found in the database (by
  # email), it will send an external invitation out.
  # 
  # Raises AlreadyInvited if the user is already invited to the survey.
  
  def create
    @survey = current_organization.surveys.running.find(params[:survey_id])
    
    invited_organization = Organization.find_by_email(params[:invitation][:email])
    
    if invited_organization.nil? then
      # create an external invitation
      @invitation = @survey.external_invitations.new(params[:invitation])
      @invitation.inviter = current_organization
    else
      # Check for duplicate invite.
      raise AlreadyInvited if invited_organization.survey_invitations.collect(&:survey_id).include?(@survey.id)
      
      # create an internal invitation.
      @invitation = @survey.invitations.new(:invitee => invited_organization, :inviter => current_organization)
    end
    
    if @invitation.save then
      if invited_organization.nil? then
        flash[:message] = "Invitation sent to external email address #{params[:invitation][:email]}."
      else
        flash[:message] = "Invitation sent to #{invited_organization.name}."
      end
      respond_to do |wants|
        wants.html { redirect_to survey_invitations_path(params[:survey_id]) }
        wants.xml { head :status => :created }
      end
    else
      respond_to do |wants|
        wants.html do

          @invitations = @survey.invitations.find(:all, :include => :invitee)
          render :action => 'index'
        end
        wants.xml { render :xml => @invitation.errors.to_xml, :status => 422 }
      end
    end
    
  rescue AlreadyInvited
    flash[:notice] = "#{invited_organization.name} has already been invited."
    respond_to do |wants|
      wants.html { redirect_to survey_invitations_path(params[:survey_id]) }
      wants.xml { head :status => 422 }
    end
  end
  
  def destroy
    flash[:message] = "Invitation removed."
    survey = current_organization.surveys.find(params[:survey_id])
    invitation = survey.invitations.find(params[:id])
    invitation.destroy
    
    respond_to do |wants|
      wants.html { redirect_to survey_invitations_path(params[:survey_id]) }
      wants.xml { head :status => :ok }
    end
  end
end
