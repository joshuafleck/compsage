class NetworkInvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'

  # Network invitations are created via the Network show view.
  # The type of invitation depends on the params passed:
  # If an organization_id is passed, an internal network invitation is created
  # If an external_invitation is passed (email and org name), an external invitation is created
  #
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
      @members = @network.organizations.find(:all, :conditions => ['organizations.id <> ?', current_organization.id])  
      render :template => '/networks/show'
    end
  end    

  def decline
    invitation = current_organization.network_invitations.find(params[:id])
    invitation.destroy
    
    respond_to do |wants|
      wants.html do
        redirect_to networks_path()
      end
    end    
  end  
  
end
