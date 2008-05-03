class NetworksController < ApplicationController
  before_filter :login_required
  
  # List all the networks.
  def index
    @networks = current_organization.networks
    
    respond_to do |wants|
      wants.html # render template
      wants.xml do
        render :xml => @networks.to_xml
      end
    end
  end
  
  # Show a specific network that the current organization is a member of.
  def show
    @network = current_organization.networks.find(params[:id], :include => :organizations)
    
    respond_to do |wants|
      wants.html # render template
      wants.xml do
        render :xml => @network.to_xml(:include => :organizations)
      end
    end
  end
  
  def new
    # show new template.
  end
  
  # edit a network that the organization owns.
  def edit
    @network = current_organization.owned_networks.find(params[:id])
  end
  
  # create a new network
  def create
    @network = current_organization.owned_networks.new(params[:network])
    @network.save!
    current_organization.networks << @network
    
    respond_to do |wants|
      wants.html { redirect_to network_invitations_path(@network) }
      
      wants.xml do
        render :status => :created
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |wants|
      wants.html do
        render :action => 'new'
      end
      wants.xml do
        render :xml => @network.errors.to_xml, :status => 422
      end
    end
  end
  
  # update a network that the current organization owns.
  def update
    @network = current_organization.owned_networks.find(params[:id])
    @network.update_attributes!(params[:network])
    
    respond_to do |wants|
      wants.html do
        flash[:notice] = "Your network was updated successfully."
        redirect_to network_path(@network)
      end
      wants.xml do
        render :status => :ok
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |wants|
      wants.html do
        render :action => 'edit'
      end
      wants.xml do
        render :xml => @network.errors.to_xml, :status => 422
      end
    end
  end
  
  # leave a network.  Redirects to the network edit page if the current organization
  # owns the network so that they can designate a new owner.
  def leave
    @network = current_organization.networks.find(params[:id])
    if @network.owner == current_organization then
      respond_to do |wants|
        wants.html do
          flash[:error] = "You must first designate a new network owner."
          redirect_to edit_network_path(@network)
        end
        wants.xml do
          render :status => :bad_request
        end
      end
    else
      current_organization.networks.delete(@network)
      
      respond_to do |wants|
        wants.html do
          flash[:notice] = "You have successfully left the network."
          redirect_to networks_path
        end
        wants.xml do
          render :status => :ok
        end
      end
    end
  end
  
  # joins a network, assuming the current organization has an invite.
  def join
    network_invite = current_organization.network_invitations.find_by_network_id(params[:id])
    if network_invite.nil? then
      respond_to do |wants|
        wants.html do
          flash[:error] = "You get an invite before joining that network."
          redirect_to networks_path
        end
        wants.xml do
          render :status => :not_authorized
        end
      end
    else
      current_organization.networks << network_invite.network
      network_invite.destroy
      
      respond_to do |wants|
        wants.html do
          flash[:notice] = "You have joined the network!"
          redirect_to network_path(network_invite.network)
        end
        wants.xml do
          render :status => :ok
        end
      end
    end
  end
  
end