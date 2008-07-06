class InvitationsController < ApplicationController

  before_filter :login_required
  layout 'logged_in'

  def index
    @page_title = "My Invitations"
    
    respond_to do |wants|
      wants.html do
        @survey_invitations = current_organization.survey_invitations
        @network_invitations = current_organization.network_invitations    
        
      end
      wants.xml do      
        @invitations = current_organization.invitations
      	render :xml => @invitations.to_xml 
      end
    end
    
  end
  
  def destroy
    @page_title = "My Invitations"
    
    @invitation = current_organization.invitations.find(params[:id])
    
    @invitation.destroy
    
    respond_to do |wants|
      wants.html {         
        flash[:notice] = "The invitation was deleted successfully."
        redirect_to invitations_path }      
      wants.xml do
        render :status => :ok
      end
    end
  end

end
