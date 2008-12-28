class NetworksController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  # List all the networks.
  def index
        
    respond_to do |wants|
      wants.html do
        @networks = current_organization.networks.paginate(:page => params[:page], :order => "name")
      end
      wants.xml do
        @networks = current_organization.networks
        render :xml => @networks.to_xml
      end
    end
  end
  
  # Show a specific network that the current organization is a member of.
  def show
    @network = current_organization.networks.find(params[:id])
    
    respond_to do |wants|
      wants.html # render template
      wants.xml do
        render :xml => @network.to_xml(:include => :organizations)
      end
    end
  end
  
  def new
    @network = Network.new
  end
  
  # edit a network that the organization owns.
  def edit
    @network = current_organization.owned_networks.find(params[:id])
  end
  
  # create a new network
  def create
    @network = current_organization.owned_networks.new(params[:network])
    
    if @network.save then
      respond_to do |wants|
        wants.html { redirect_to network_invitations_path(@network) }
      
        wants.xml do
          head :status => :created
        end
      end
    else
      respond_to do |wants|
        wants.html do
          render :action => 'new'
        end
        wants.xml do
          render :xml => @network.errors.to_xml, :status => 422
        end
      end
    end
  end
  
  # update a network that the current organization owns.
  def update
    @network = current_organization.owned_networks.find(params[:id])
    @network.attributes = params[:network]
    
    if @network.save then
      respond_to do |wants|
        wants.html do
          redirect_to network_path(@network)
        end
        wants.xml do
          render :status => :ok
        end
      end
    else
      respond_to do |wants|
        wants.html do
          render :action => 'edit'
        end
        wants.xml do
          render :xml => @network.errors.to_xml, :status => 422
        end
      end
    end
  end
  
  # leave a network.  Redirects to the network edit page if the current organization
  # owns the network so that they can designate a new owner.
  def leave
    @network = current_organization.networks.find(params[:id])
    if @network.owner == current_organization && @network.organizations.count > 1 then
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
    network_invite = current_organization.network_invitations.find_by_network_id(params[:id], :include => :network)
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
      network_invite.accept!
      
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
  
  # This method enables a network owner to remove organizations from the network
  def evict
    @network = current_organization.owned_networks.find(params[:id])
    @organization = @network.organizations.find(params[:organization_id])
    
    @network.organizations.delete(@organization) if @network.owner != @organization
    
    if @network.save then
      respond_to do |wants|
        wants.html do
          flash[:notice] = "#{@organization.name} was removed from the network"
          redirect_to network_path(@network)
        end
        wants.xml do
          render :status => :ok
        end
      end
    else
      respond_to do |wants|
        wants.html do
          flash[:notice] = "Unable to remove #{@organization.name} from the network. Please try again later."
          redirect_to network_path(@network)
        end
        wants.xml do
          render :xml => @network.errors.to_xml, :status => 422
        end
      end
    end
  end
  
end
