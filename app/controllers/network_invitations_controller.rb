class NetworkInvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def index
    @network = current_organization.owned_networks.find(params[:network_id])
    @invitations = @network.all_invitations
    @invalid_invitations = []
    
    respond_to do |wants|
      wants.html {} # render the template
      wants.xml { render :xml => @invitations.to_xml }
    end
  end
  
  def create
    @network = current_organization.owned_networks.find(params[:network_id]) 
    
    invitees = []  
    external_invitees = []
    network_invitees = []
       
    # find all of the individual invited organizations    
    params[:invite_organization].each do |id, invite|
      if invite[:included] == "1" then
        invitees << Organization.find_by_id(id) 
      end
    end unless params[:invite_organization].blank?
    
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
      @network)

    respond_to do |wants|
      wants.html do
        @invitations = @network.all_invitations
        flash[:notice] = sent_invitations.size > 0 ? "Invitations sent!" : "No invitations were sent"
        render :action => "index"
      end
      wants.js do
        render :text => sent_invitations.size > 0 ? "Invitation sent!" : "Selected invitee was already invited."
      end
    end 
  end    
  
  def destroy
    network = current_organization.owned_networks.find(params[:network_id])
    invitation = network.invitations.find(params[:id])
    invitation.destroy
    
    respond_to do |wants|
      wants.html { redirect_to network_invitations_path(params[:network_id]) }
      wants.xml { head :status => :ok }
    end
  end
  
  def decline
    invitation = current_organization.network_invitations.find(params[:id])
    invitation.destroy
    
    respond_to do |wants|
      wants.html { redirect_to networks_path() }
      wants.xml { head :status => :ok }
    end    
  end  
  
end
