class NetworksController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  # List all the networks.
  def index
    @network_invitations = current_organization.network_invitations
    @networks = current_organization.networks.paginate(:page => params[:page], :order => "name")
  end
  
  # Show a specific network that the current organization is a member of.
  def show
    @network = current_organization.networks.find(params[:id])
    @members = @network.organizations.find(:all, :conditions => ['organizations.id <> ?', current_organization.id])  
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
      redirect_to network_path(@network) 
    else
      render :action => 'new'
    end
  end
  
  # update a network that the current organization owns.
  def update
    @network = current_organization.owned_networks.find(params[:id])
     
    if @network.update_attributes(params[:network]) then
      redirect_to network_path(@network)
    else
      render :action => 'edit'
    end
  end
  
  # Leave a network.  Redirects to the network page.
  # if user is the network owner, and new owner is automatically assigned.
  def leave
    @network = current_organization.networks.find(params[:id])

    current_organization.networks.delete(@network)
    redirect_to networks_path
  end
  
  # joins a network, assuming the current organization has an invite.
  def join
    network_invite = current_organization.network_invitations.find_by_network_id(params[:id], :include => :network)
    if network_invite.nil? then
      flash[:notice] = "You must get an invite before joining that network."
      redirect_to networks_path
    else
      network_invite.accept!
      flash[:notice] = "You have joined the network!"
      redirect_to network_path(network_invite.network)
    end
  end
  
  # This method enables a network owner to remove organizations from the network
  def evict
    @network = current_organization.owned_networks.find(params[:id])
    @organization = @network.organizations.find(params[:organization_id])
    
    @network.organizations.delete(@organization) if @network.owner != @organization
    
    if @network.save then
      flash[:notice] = "#{@organization.name} was removed from the network"
      redirect_to network_path(@network)
    else
      flash[:notice] = "Unable to remove #{@organization.name} from the network. Please try again later."
      redirect_to network_path(@network)
    end
  end
  
end
