class NetworkInvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def index
    @network = current_organization.owned_networks.find(params[:network_id])
    
    @invitations = @network.invitations
    
    respond_to do |wants|
      wants.html {} # render the template
      wants.xml { render :xml => @invitations.to_xml }
    end
  end
  
  def new
    # render the new template
  end
  
  # Creates the new network invitation.  If the organization is not found in the database (by
  # email), it will send an external invitation out.
  
  def create
    network = current_organization.owned_networks.find(params[:network_id])
    invited_organization = Organization.find_by_email(params[:email])
    
    if invited_organization.nil? then
      # send the external invitation
      network_invitation = network.external_invitations.new(:inviter => invited_organization, :email => params[:email])
    else
      # send the internal invitation.
      network_invitation = network.invitations.new(:invitee => invited_organization, :inviter => current_organization)
    end
    
    if network_invitation.save then
      flash[:message] = "Invitation sent!"
      respond_to do |wants|
        wants.html { redirect_to network_invitations_path(params[:network_id]) }
        wants.xml { head :status => :created }
      end
    else
      respond_to do |wants|
        wants.html { redirect_to network_invitations_path(params[:network_id]) }
        wants.xml { render :xml => @network.errors.to_xml, :status => 422 }
      end
    end
  end
  
  def destroy
    flash[:message] = "Invitation removed."
    network = current_organization.owned_networks.find(params[:network_id])
    invitation = network.invitations.find(params[:id])
    invitation.destroy
    
    respond_to do |wants|
      wants.html { redirect_to network_invitations_path(params[:network_id]) }
      wants.xml { head :status => :ok }
    end
  end
  
end
