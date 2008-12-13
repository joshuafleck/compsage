class SurveyInvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def index
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @invitations = @survey.all_invitations
    @invalid_external_invites = []
    
    respond_to do |wants|
      wants.html {} # render the template
      wants.xml { render :xml => @invitations.to_xml }
    end
  end
  
  def new
    # render the new template
  end
  
  def create
    @survey = current_organization.sponsored_surveys.running.find(params[:survey_id])    
    @invalid_external_invites = []     
    invite_organizations = []
    invitations_sent = false
       
    # find all of the individual invited organizations    
    params[:invite_organization].each do |id, invite|
      if invite[:included] == "1" then
        invite_organizations << Organization.find_by_id(id) 
      end
    end unless params[:invite_organization].blank?
    
    # find all of the organizations belonging to invited networks 
    params[:network].each do |id, invite|
      if invite[:included] == "1" then
        network = current_organization.networks.find(id)
        invite_organizations += network.organizations
      end
    end unless params[:network].blank?
    
    # create invitations for all invited organizations not already invited
    invite_organizations.uniq.each do |invite_organization|
      if !invite_organization.invited_surveys.include?(@survey) && invite_organization != @survey.sponsor then
        invitation = @survey.invitations.new(:invitee => invite_organization, :inviter => current_organization)
        invitation.save!
        invitations_sent = true
      end
    end
    
    # create the external invitations
    params[:external_invite].each do |id, invite|
      if !invite[:included].blank? then
        invitation = @survey.external_invitations.new(invite)
        invitation.inviter = current_organization
        if !invitation.save then
          @invalid_external_invites << invitation
        else
          invitations_sent = true
        end
      end
    end unless params[:external_invite].blank?
    
    # if there was a problem creating any external invitations, re-render the index page
    if @invalid_external_invites.size > 0 then
      respond_to do |wants|
        @invitations = @survey.all_invitations
        wants.html do
          render :action => "index"
        end
      end 
    else
      flash[:notice] = invitations_sent ? "Invitations sent!" : "No invitees were selected, or selected invitees were already invited."
      respond_to do |wants|
        wants.html do
          redirect_to :action => "index"
        end
      end     
    end
  end
    
  def destroy
    survey = current_organization.sponsored_surveys.find(params[:survey_id])
    invitation = survey.invitations.find(params[:id])
    invitation.destroy
    
    respond_to do |wants|
      wants.html { redirect_to survey_invitations_path(params[:survey_id]) }
      wants.xml { head :status => :ok }
    end
  end
  
  def decline
    invitation = current_organization.survey_invitations.find(params[:id])
    invitation.decline!
    
    respond_to do |wants|
      wants.html { redirect_to surveys_path() }
      wants.xml { head :status => :ok }
    end    
  end
end
