class SurveyInvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def index
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @invitations = @survey.invitations.find(:all, :include => :invitee)
    @external_invitations = @survey.external_invitations.find(:all)
    
    respond_to do |wants|
      wants.html {} # render the template
      wants.xml { render :xml => (@invitations + @external_invitations).to_xml }
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
    @survey = current_organization.sponsored_surveys.running.find(params[:survey_id])
    
    # If there is an organization ID in the params great (this request likely came from the Memebrs page), otherwise use the email
    if !params[:organization_id].blank? then
      invited_organization = Organization.find_by_id(params[:organization_id]) 
    else
      invited_organization = Organization.find_by_email(params[:invitation][:email])
    end
    
    if invited_organization.nil? then
      # create an external invitation
      @invitation = @survey.external_invitations.new(params[:invitation])
      @invitation.inviter = current_organization
    else
      # Check for duplicate invite.
      raise AlreadyInvited if invited_organization.survey_invitations.collect(&:survey_id).include?(@survey.id)
      # Check for sponsor inviting themself. This is not allowed
      raise SelfInvitation if invited_organization == @survey.sponsor
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
        wants.js { render :text => "Invitation to #{@survey.job_title} sent to #{invited_organization.name}."}
      end
    else
      respond_to do |wants|
        wants.html do

          @invitations = @survey.invitations.find(:all, :include => :invitee)
          @external_invitations = @survey.external_invitations.find(:all)
          render :action => 'index'
        end
        wants.xml { render :xml => @invitation.errors.to_xml, :status => 422 }
        wants.js { render :text => "Error creating invitation for #{@survey.job_title}"}
      end
    end
    
  rescue AlreadyInvited
    flash[:notice] = "#{invited_organization.name} has already been invited."
    respond_to do |wants|
      wants.html { redirect_to survey_invitations_path(params[:survey_id]) }
      wants.xml { head :status => 422 }
      wants.js { render :text => "#{invited_organization.name} has already been invited to #{@survey.job_title}."}
    end
  rescue SelfInvitation
    flash[:notice] = "As the survey sponsor, you cannot be an invitee to your own survey."
    respond_to do |wants|
      wants.html { redirect_to survey_invitations_path(params[:survey_id]) }
      wants.xml { head :status => 422 }
      wants.js { render :text => flash[:notice]}
    end
  end
  
  #This method is for inviting a network to participate in a survey
  def create_with_network
    @survey = current_organization.sponsored_surveys.running.find(params[:survey_id])
    @network = current_organization.networks.find(params[:invitation][:network_id])
    
    #Create an invitation for each network member
    @network.organizations.each do |member| 
      #Do not invite members already invited or the survey sponsor
      if !member.survey_invitations.collect(&:survey_id).include?(@survey.id) && !(member == @survey.sponsor) then
        invitation = @survey.invitations.new(:invitee => member, :inviter => current_organization)
        invitation.save!
      end
    end

    flash[:message] = "Invitation sent to all members of #{@network.name}."
    respond_to do |wants|
      wants.html { redirect_to survey_invitations_path(params[:survey_id]) }
      wants.xml { head :status => :created }
    end
  end
  
  def destroy
    flash[:message] = "Invitation removed."
    survey = current_organization.sponsored_surveys.find(params[:survey_id])
    invitation = survey.invitations.find(params[:id])
    invitation.destroy
    
    respond_to do |wants|
      wants.html { redirect_to survey_invitations_path(params[:survey_id]) }
      wants.xml { head :status => :ok }
    end
  end
end
