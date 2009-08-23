class SurveyInvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def index
    @networks = current_organization.networks   
    @survey   = current_organization.sponsored_surveys.find(params[:survey_id])

    if session[:survey_network_id] then
      # Why, it looks like we want to survey a network!
      create_invitations_for_network(current_organization.networks.find(session[:survey_network_id]))
      session.delete(:survey_network_id)
    end

    @invitations = @survey.internal_and_external_invitations

    respond_to do |wants|
      wants.html # render the template
    end
  end
  
  # This will attempt to create an internal or external invitation, depending on the params passed:
  # If an organization_id is passed, an internal survey invitation is created
  # If an external_invitation is passed (email and org name), an external invitation is created
  #
  def create
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])    

    @invitation = if params[:organization_id] then
      invite_organization
    elsif params[:external_invitation] then
      invite_external_organization
    end
    
    @invitation.save

    respond_to do |wants|
      wants.js
    end
    
  end
   
  # Creates a set of survey invitations for a network. This will just do the best it can to invite the entire network
  # (excluding, of course, the sponsor). If the invitation cannot be saved due to a validation error (eg., if the
  # network member is already invited), the invitation will just be silently skipped.
  #
  # This action is currently only available via post, and will only respond to javascript, as it's currently used by
  # the invitation list during survey creation only.
  def create_for_network
    @survey  = current_organization.sponsored_surveys.find(params[:survey_id])
    @network = current_organization.networks.find(params[:network_id])

    @invitations = create_invitations_for_network(@network)

    respond_to do |wants|
      wants.js
    end
  end

  def destroy
    survey     = current_organization.sponsored_surveys.find(params[:survey_id])
    invitation = survey.internal_and_external_invitations.find(params[:id])
    invitation.destroy
    
    respond_to do |wants|
      wants.js do
        head :status => :ok
      end
    end
  end
  
  def decline
    invitation = current_organization.survey_invitations.find(params[:id])
    invitation.decline!
    
    respond_to do |wants|
      wants.html do
        redirect_to surveys_path()
      end
    end    
  end

  # This will send out all of the pending invitations, typically when a survey is started.
  # The purpose of this is twofold. 
  # 1. It allows the sponsor to edit the invitation list
  # 2. It does not send invitations before the billing information has been received
  #
  def send_pending
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @survey.internal_and_external_invitations.pending.each do |invitation|
      invitation.send_invitation!
    end

    redirect_to survey_path(@survey)
  end
  
  private

  # Invite the organization contained in the organization_id param.
  #
  def invite_organization
    organization = Organization.find(params[:organization_id]) 

    return @survey.invitations.new(:inviter => current_organization, :invitee => organization)
  end
  
  # Invite the organization contained in the external_invitation param. This is used to invite an organization by email
  # address.
  #
  def invite_external_organization
    invitation = Invitation.new_external_invitation_to(@survey, params[:external_invitation])
    invitation.inviter = current_organization

    return invitation
  end

  # Creates the a set of survey_invitations, one for each member of the network. Any invalid invitations will be
  # skipped silently.
  #
  def create_invitations_for_network(network)
    invitations = []
    network.organizations.each do |organization|
      next if organization == current_organization

      invitation = @survey.invitations.create(:inviter => current_organization, :invitee => organization)

      invitations << invitation if invitation.valid?
    end

    invitations
  end
end
