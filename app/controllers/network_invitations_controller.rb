class NetworkInvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def index
    @network = current_organization.owned_networks.find(params[:network_id])
    @invitations = @network.invitations.find(:all, :include => :invitee)
    
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
  # 
  # Raises AlreadyInvited if the user is already invited to the network.
  
  def create
    @network = current_organization.owned_networks.find(params[:network_id])
    
    invited_organization = Organization.find_by_email(params[:email])
    
    if invited_organization.nil? then
      # create an external invitation
      @invitation = @network.external_invitations.new(:inviter => current_organization, :email => params[:email])
    else
      # Check for duplicate invite.
      raise AlreadyInvited if invited_organization.network_invitations.collect(&:network_id).include?(@network.id)
      
      # create an internal invitation.
      @invitation = @network.invitations.new(:invitee => invited_organization, :inviter => current_organization)
    end
    
    if @invitation.save then
      if invited_organization.nil? then
        flash[:message] = "Invitation sent to external email address #{params[:email]}."
      else
        flash[:message] = "Invitation sent to #{invited_organization.name}."
      end
      respond_to do |wants|
        wants.html { redirect_to network_invitations_path(params[:network_id]) }
        wants.xml { head :status => :created }
      end
    else
      respond_to do |wants|
        wants.html do
          # get ready to render the index template again.

          @invitations = @network.invitations.find(:all, :include => :invitee)
          render :action => 'index'
        end
        wants.xml { render :xml => @invitation.errors.to_xml, :status => 422 }
      end
    end
    
  rescue AlreadyInvited
    flash[:notice] = "#{invited_organization.name} has already been invited."
    respond_to do |wants|
      wants.html { redirect_to network_invitations_path(params[:network_id]) }
      wants.xml { head :status => 422 }
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
