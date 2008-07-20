class ExternalInvitationsController < ApplicationController

  before_filter :login_required
  layout 'logged_in'
  
  def index
  
    @invitations = current_organization.sent_global_invitations
  
    respond_to do |wants|
      wants.html
      wants.xml do
      	render :xml => @invitations.to_xml 
      end
    end
    
  end
  
  def new
    
    @invitation = ExternalInvitation.new  
  end
  
  def create
    
    @invitation = current_organization.sent_global_invitations.new(params[:invitation])
    
    if @invitation.save then
      respond_to do |wants|
        wants.html {         
          flash[:notice] = "Invitation sent to external email address #{params[:invitation][:email]}."
          redirect_to external_invitations_path }      
        wants.xml do
          render :status => :created
        end
      end
    else
      respond_to do |wants|
        wants.html do
        
          @invitations = current_organization.sent_global_invitations
  
          render :action => 'index'
        end
        wants.xml do
          render :xml => @invitation.errors.to_xml, :status => 422
        end
      end
    
    end
  
  end

end
