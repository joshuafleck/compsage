class InvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'

  def index
    
    respond_to do |wants|
      wants.html do
        @survey_invitations = current_organization.survey_invitations.running.find(:all, :order => 'invitations.created_at desc')
        @network_invitations = current_organization.network_invitations.find(:all, :order => 'invitations.created_at desc')        
      end
      wants.xml do      
        @invitations = current_organization.invitations
      	render :xml => @invitations.to_xml 
      end
    end    
  end
  
  def destroy
    
    @invitation = current_organization.invitations.find(params[:id])
    
    @invitation.destroy
    
    respond_to do |wants|
      wants.html do 
        flash[:notice] = "The invitation was deleted successfully."
        redirect_to invitations_path
      end
      wants.xml do
        render :status => :ok
      end
    end
  end

end
