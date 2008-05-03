class NetworksController < ApplicationController
  before_filter :login_required
  
  def index
    @networks = current_organization.networks
    
    respond_to do |wants|
      wants.html # render template
      wants.xml do
        render :xml => @networks.to_xml
      end
    end
  end
  
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
  
  def edit
    @network = current_organization.owned_networks.find(params[:id])
  end
  
  def create
    network = current_organization.owned_networks.new(params[:network])
    network.save!
    current_organization.networks << network
    
    respond_to do |wants|
      wants.html { redirect_to network_invitations_path(network) }
      
      wants.xml do
        render :status => :created
      end
    end
  rescue ActiveRecord::RecordInvalid
    # handle validation
  end
  
  def update
    network = current_organization.owned_networks.find(params[:id])
    network.update_attributes!(params[:network])
    
    respond_to do |wants|
      wants.html do
        flash[:notice] = "Your network was updated successfully."
        redirect_to network_path(network)
      end
      wants.xml do
        render :status => :ok
      end
    end
  rescue ActiveRecord::RecordInvalid
    # handle validation
  end
end