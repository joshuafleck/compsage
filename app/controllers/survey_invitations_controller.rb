class SurveyInvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def index
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @invitations = @survey.all_invitations
    @invalid_invitations = []
    @networks = current_organization.networks   
    
    # if this came from a survey network link, be sure to mark the network as selected
    @networks.each do |network|
      if network.id.to_s == session[:survey_network_id] then
        network.included = "1"
        session[:survey_network_id] = nil
      end    
    end unless session[:survey_network_id].blank?
    
    respond_to do |wants|
      wants.html {} # render the template
      wants.xml { render :xml => @invitations.to_xml }
    end
  end
  
  def create
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    
    invitees = []  
    external_invitees = []
    network_invitees = []
       
    # find all of the individual invited organizations    
    params[:invite_organization].each do |id, invite|
      if invite[:included] == "1" then
        invitees << Organization.find_by_id(id) 
      end
    end unless params[:invite_organization].blank?

    # find all of the invited networks
    params[:network].each do |id, invite|
      if invite[:included] == "1" then
        network_invitees << current_organization.networks.find(id)
      end
    end unless params[:network].blank?
    
    # find the invited external invitations
    params[:external_invite].each do |id, invite|
      if !invite[:included].blank? then
        external_invitees << invite
      end
    end unless params[:external_invite].blank?
    
    # the invitation model will take care of creating the invitations
    sent_invitations, @invalid_invitations = Invitation.create_internal_or_external_invitations(
      external_invitees,
      invitees,
      network_invitees,
      current_organization,
      @survey)
    
    respond_to do |wants|
      wants.html do
        @invitations = @survey.all_invitations
        @networks = current_organization.networks
        flash[:notice] = sent_invitations.size > 0 ? "Invitations sent!" : "No invitations were sent"
        render :action => "index"
      end
      wants.js do
        render :text => sent_invitations.size > 0 ? "Invitation sent!" : "Selected invitee was already invited."
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
