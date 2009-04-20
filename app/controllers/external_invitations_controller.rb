class ExternalInvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def index
  
    @invitations = current_organization.sent_global_invitations.find(:all, :order => 'created_at desc')
  
    respond_to do |wants|
      wants.xml do
      	render :xml => @invitations.to_xml 
      end
    end    
  end
  
  def create
    
    @invitation = current_organization.sent_global_invitations.new(params[:invitation])
    
    existing_organization = Organization.find_by_email(params[:invitation][:email])
    
    #We do not want to send an external invitation if the organization has already joined
    raise ExistingOrganization if !existing_organization.nil?
    
    if @invitation.save then
      respond_to do |wants|  
        wants.xml do
          head :status => :created
        end
      end
    else
      respond_to do |wants|
        wants.xml do
          render :xml => @invitation.errors.to_xml, :status => 422
        end
      end    
    end  
    
  rescue ExistingOrganization
    respond_to do |wants|
      wants.xml do
        head :status => 422
      end
    end    
  end

end
