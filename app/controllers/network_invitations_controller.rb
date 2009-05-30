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

    @invitation = if params[:organization_id] then
      organization = Organization.find(params[:organization_id])
      @network.invitations.new(:invitee => organization, :inviter => current_organization)
    elsif params[:external_invitation] then
      Invitation.new_external_invitation_to(@network, params[:external_invitation].merge(:inviter => current_organization))
    end
    
    if @invitation.save then
      if @invitation.is_a?(ExternalNetworkInvitation) then
        flash[:notice] = "Invitation sent to #{@invitation.organization_name}"
      else
        flash[:notice] = "Invitation sent to #{@invitation.invitee.name}"
      end

      redirect_to network_path(@network)
    else
      # Load @members, required for the networks show view.
      @members = @network.organizations
      render :template => '/networks/show'
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
