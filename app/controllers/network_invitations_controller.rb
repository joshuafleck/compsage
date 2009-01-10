class NetworkInvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def index
    @network = current_organization.owned_networks.find(params[:network_id])
    @invitations = @network.all_invitations
    @invalid_external_invites = []
    
    respond_to do |wants|
      wants.html {} # render the template
      wants.xml { render :xml => @invitations.to_xml }
    end
  end
  
  # Creates the new network invitation.  If the organization is not found in the database (by
  # email), it will send an external invitation out.
  #   
  def create
    @network = current_organization.owned_networks.find(params[:network_id])   
    @invalid_external_invites = []
    invitations_sent = false
       
    # find all of the individual invited organizations    
    params[:invite_organization].each do |id, invite|
      if invite[:included] == "1" then
        organization = Organization.find_by_id(id) 
        if !organization.invited_networks.include?(@network) && !organization.networks.include?(@network) then
          invitation = @network.invitations.new(:invitee => organization, :inviter => current_organization)
          invitation.save!
          invitations_sent = true
        end       
      end
    end unless params[:invite_organization].blank?
    
    # create the external invitations
    params[:external_invite].each do |id, invite|
      if !invite[:included].blank? then
        invitation = @network.external_invitations.new(invite)
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
        @invitations = @network.all_invitations
        wants.html do
          render :action => "index"
        end
      end 
    else
      respond_to do |wants|
        wants.html do
          flash[:notice] = invitations_sent ? "Invitations sent!" : "No invitees were selected, or selected invitees were already invited."
          redirect_to :action => "index"
        end
        wants.js do
          render :text => invitations_sent ? "Invitation sent!" : "Selected invitee was already invited."
        end
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
