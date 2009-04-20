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
        head :status => :ok
      end
    end
  end

  # Create invitations to networks or surveys from the currently logged in user.
  def create
    invitee = Organization.find(params[:organization][:id])
    invitation = nil
    if params[:network] then
      network = current_organization.owned_networks.find(params[:network][:id])
      unless network.invitations.find(:first, :conditions => {:invitee_id => invitee}) || network.organizations.include?(invitee) then
        invitation = network.invitations.create!(:invitee => invitee, :inviter => current_organization)
      end
    elsif params[:survey]
      survey = current_organization.sponsored_surveys.running.find(params[:survey][:id])
      unless survey.invitations.find(:first, :conditions => {:invitee_id => invitee}) then
        invitation = survey.invitations.create!(:invitee => invitee, :inviter => current_organization)
      end
    end

    if invitation then 
      if invitation.valid? then
        respond_to do |wants|
          wants.xml do
            head :status => :created
          end
        end
      else
        respond_to do |wants|
          wants.xml do
            render :xml => invitation.errors.to_xml, :status => 422
          end
        end
      end
    else
      respond_to do |wants|
        wants.xml do
          head :status => 422
        end
      end
    end
  end

end
