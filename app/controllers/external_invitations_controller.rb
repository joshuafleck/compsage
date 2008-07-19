class ExternalInvitationsController < ApplicationController

  before_filter :login_required
  layout 'logged_in'
  
  def index
  
    @external_invitations = current_organization.sent_global_invitations
  
    respond_to do |wants|
      wants.html
      wants.xml do
      	render :xml => @external_invitations.to_xml 
      end
    end
    
  end
  
  def new
    
    @external_invitation = ExternalInvitation.new  
  end
  
  def create
    
    @external_invitation = current_organization.sent_global_invitations.new(params[:external_invitation])
    
    if @external_invitation.save then
      respond_to do |wants|
        wants.html {         
          flash[:notice] = "Your invitation was created successfully."
          redirect_to external_invitations_path }      
        wants.xml do
          render :status => :created
        end
      end
    else
      respond_to do |wants|
        wants.html do
          render :action => 'new'
        end
        wants.xml do
          render :xml => @external_invitation.errors.to_xml, :status => 422
        end
      end
    
    end
  
  end

end
