class AccountsController < ApplicationController
  include NewOrganizationHelper
  before_filter :login_required, :except => [ :new , :create, :forgot, :reset, :activate, :deactivate ]
  before_filter :locate_invitation, :only => [ :new , :create ]
  before_filter :locate_existing_organization, :only => [ :new ]
  layout :logged_in_or_invited_layout 
  filter_parameter_logging :password

  def new
  
    # Prepopulate the name and email fields automagically from the invitation
    @organization = Organization.new(:invitation => @invitation)  
    
  end
  
  def edit
    @organization = current_organization
  end
  
  def create
  
    @organization = Organization.new(params[:organization].merge(:invitation => @invitation))

    # Do not require the captcha if the invitation is present, as we know it only a human can present a valid key
    if (@invitation || verify_recaptcha(:model => @organization, :message => 'The Captcha input was incorrect. Please try again.')) && @organization.save then
            
      # Accepts the invitation, which will add the survey/network to the newly created organization
      send_email_and_move_invitations_to_new_organization(@organization, @invitation)
  
      # Clear the existing session, we don't want any invitations hanging around
      logout_killing_session!

      login_organization({
          :organization => @organization, 
          :new_cookie_flag => false, 
          :url => '/'})
      
    else      
      render :action => 'new'
    end
    
  end
  
  # This will locate the organization by the activation key, activate the organization, and log them in
  #
  def activate
    organization = Organization.find_by_activation_key(params[:key])
    
    if organization then 
    
      organization.activate
      flash[:notice] = "Your account has been activated! Please take a few moments to tell us more about yourself."
      
      # Will attempt to tie external invitations that share the same email address as the organization
      move_external_invitations_to_organization(organization)
      
      login_organization({
          :organization => organization, 
          :new_cookie_flag => false, 
          :url => edit_account_path})      
      
    else
    
      flash[:notice] = "We are unable to activate your account at this time. If the problem persists, <a href=\"#{contact_path}\">let us know</a>."
      redirect_to new_session_path
      
    end
    
  end
  
  # This method is called via a link in the welcome email. Its
  #  purpose is to disable an account if a user believes someone
  #  created a CS account using their email address without their
  #  knowledge/permission
  def deactivate
   organization = Organization.find_by_deactivation_key(params[:key])
    
    if organization && !organization.deactivated? then 
    
      organization.deactivate
      flash[:notice] = "This account has been disabled and the administrator has been notified."
      
      Notifier.deliver_report_account_deactivation(organization)
      
    else
    
      flash[:notice] = "We are unable to locate the account at this time. If the problem persists, <a href=\"#{contact_path}\">let us know</a>."
      
    end
    
    redirect_to new_session_path
    
  end
  
  def update
  
    @organization = current_organization  
          
    if @organization.update_attributes(params[:organization]) then
      flash[:notice] = "Your account was updated successfully."
      redirect_to edit_account_path
    else
      render :action => 'edit'
    end
        
  end
  
  # Forgot password functionality. Allows the user to make a password reset request.
  # Behavior depends on request type:
  #   @get: Will present the reset password form to the user
  #   @put: Will trigger the reset process by creating a reset key and sending the key to the user
  #
  def forgot
  
    if request.put?
    
      organization = Organization.is_not_uninitialized_association_member.find_by_email(params[:email])      
      if organization then
      
        # This will prevent email bombing of the forgot password link.
        if organization.can_request_password_reset? then
        
          organization.create_reset_key_and_send_reset_notification
          
          flash[:notice] = "An email containing a link to reset your password was sent to #{organization.email}."
          redirect_to new_session_path 
         
        else
         
          flash.now[:notice] = "You have already requested a password reset. If you did not receive an email containing a link to reset your password, <a href=\"#{contact_path}\">let us know</a>."
          
        end
        
      else
        flash.now[:notice] = "There was no account found for #{params[:email]}."
      end
    end
    
  end
  
  # Reset password functionality. Allows the user to change their password.
  # Behavior depends on request type:
  #   @get: Will present the change password form to the user
  #   @put: Will update the user's password
  #
  def reset
  
    @organization = Organization.find_by_reset_password_key(params[:key]) unless params[:key].blank?
    # A PUT request was made, attempt to change the password.
    if request.put?
      if @organization.update_attributes(params[:organization])
        
        @organization.delete_reset_key
        
        flash[:notice] = "Your password has been changed."
        redirect_to new_session_path
      else
        render :action => :reset
      end
    
    # A GET request was made, verify that the user's credentials are valid before presenting the change form.
    else
    
      # Do not allow an invalid key, or an expired key.
      if @organization.nil? || @organization.reset_password_key_expired? then
      
        if @organization.nil? then
          flash[:notice] = "We do not have a record of a password reset request. Please try again."
        else
          flash[:notice] = "You must change your password within 5 days of making the reset request. Please try again."
          @organization.delete_reset_key
        end
        
        redirect_to new_session_path
      end
      
    end
  end
  
  private
  
  # This will locate the invitation, if one is present.
  #
  def locate_invitation
  
    # See if a key was provided
    if !params[:key].blank? then 
    
      # Check to see if this key belongs to a network invitation.
      @invitation = ExternalNetworkInvitation.find_by_key(params[:key])
      
      # Save the invitation in the session, as the user may navigate to another page and lose their key.
      session[:invitation] = @invitation if @invitation
        
    end
  
    # The user could be logged in with a survey invitation, or have already saved their invitation in the session.
    @invitation ||= current_survey_invitation || session[:invitation]
      
  end
  
  # The purpose of this filter is to determine if the invitation email is tied to an existing organization.
  # If it is, redirect the user to the sign in page.
  #
  def locate_existing_organization
  
    if @invitation then
    
      email = @invitation.email
      organization = Organization.find_by_email(email)
      
      if organization then
      
        association = organization.association
        
        if association then       
      
          # Note that if the redirect changes the subdomain, the session will be lost, that is why we need to send 
          #  the invitation key in the redirect
          redirect_to(sign_in_association_member_url(
            :email     => email,
            :key       => @invitation.key,
            :subdomain => association.subdomain))
        else
          redirect_to(login_path(:email => email))
        end
      
      end
    
    end
  
  end

end
