class SurveyInvitationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def index
    @networks = current_organization.networks   
    @survey   = current_organization.sponsored_surveys.find(params[:survey_id])  
    
    if current_association then  
      @organizations =  current_association.organizations.all(:order => "name") 
    
      # We only need non-invited organizations
      invitees = @survey.invitees.all
      @organizations.reject!{|o| invitees.include?(o) }
    
    end
    
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
  # Set method to 'association' to not raise any error messages for invitation failures (such as duplicates).
  #
  def create
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @method = params[:method]

    @invitation = if params[:organization_id] then
      invite_organization params[:organization_id]
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
  
  # Used for invite all functionality. Creates an invitation for each organization passed in the organizations param.
  # Expects a list of IDs separated by commas.
  def create_for_association
    @survey  = current_organization.sponsored_surveys.find(params[:survey_id])
    @organizations = params[:organizations].split(",")
    @invitations = []

    @organizations.each do |organization_id|
      invitation = invite_organization(organization_id.to_s)
      invitation.save
      @invitations << invitation if invitation.valid?
    end
    
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
  
  def destroy_all
    survey = current_organization.sponsored_surveys.find(params[:survey_id])
    
    invitations = survey.internal_and_external_invitations.all.select do |x|  
      # Note that this will not remove the sponsor's invite, as that is already fulfilled
      x.inviter == current_organization && x.pending?
    end
    
    invitations.each do |invitation|
      invitation.destroy
    end
    
    respond_to do |wants|
      wants.json do
        render :json => invitations.to_json(:only => [:id])
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

  # This action receives the post data from the invitation page. If the survey is pending, it will simply update the
  # survey's invitation message, as no invitations are sent until billing info is received. If the survey is running,
  # we assume the user is editing their invitation list only.
  #
  def update_message
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])

    @survey.attributes = params[:survey]
    @survey.save

    if @survey.pending? then
      # Show the preview page.
      redirect_to preview_survey_questions_path(@survey)
    else
      # Send the new invitations and go back to the survey show page.
      @survey.internal_and_external_invitations.pending.each do |invitation|
        invitation.send_invitation!
      end

      redirect_to survey_path(@survey)
    end
  end
  
  private

  # Invite the organization contained in the organization_id param.
  #
  def invite_organization(organization_id)
    organization = Organization.find(organization_id) 

    return Invitation.new_invitation_to(@survey, { 
        :invitee => organization, 
        :inviter => current_organization
      })
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
