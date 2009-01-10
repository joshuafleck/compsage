class InvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'

  def index
    
    respond_to do |wants|
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
      wants.xml do
        render :status => :ok
      end
    end
  end

end
