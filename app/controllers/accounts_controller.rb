class AccountsController < ApplicationController
  before_filter :login_required, :except => [ :new , :create, :forgot, :reset ]
  before_filter :invitation_or_pending_account_required, :only => [ :new , :create ]
  layout :logged_in_or_invited_layout 
  filter_parameter_logging :password

  def new
  
    # Prepopulate the name and email fields automagically from the invitation or pending account
    @organization = Organization.new(:invitation_or_pending_account => @invitation_or_pending_account)  
    
  end
  
  def edit
    @organization = current_organization
  end
  
  def create
  
    @organization = Organization.new(params[:organization].merge(:last_login_at => Time.now))

    if @organization.save then
            
      if @invitation_or_pending_account.is_a?(PendingAccount) then
        @invitation_or_pending_account.destroy                  
      else    
        # The user was invited via survey or network invitation    
        @invitation_or_pending_account.accept!(@organization)    
      end
  
      # Clear the existing session, we don't want any invitations hanging around
      logout_killing_session!
      # Set first_login in the session so we can show a tutorial
      session[:first_login] = true                
      # Mark the user as logged in            
      self.current_organization = @organization 
      
      redirect_to surveys_path
      
    else      
      render :action => 'new'
    end
    
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
    
      organization = Organization.find_by_email(params[:email])      
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
  
  # In order to create an account, as user must be invited to CompSage, or have an approved sign up request.
  # This will locate the invitation or sign up request
  #
  def invitation_or_pending_account_required
  
    # Check for a survey invitation, this will be the most common use-case.
    @invitation_or_pending_account = current_survey_invitation
    
    # Check the session to see if a user was invited, but navigated away (lost their key).
    @invitation_or_pending_account ||= session[:invitation_or_pending_account]
    
    # If there was no survey invitation, see if a key was provided
    if !@invitation_or_pending_account && !params[:key].blank? then 
    
      # Check to see if this key belongs to an network invitation. Check for a pending account if no network invite was found.
      @invitation_or_pending_account = ExternalNetworkInvitation.find_by_key(params[:key]) || PendingAccount.find_by_key(params[:key])
      
      # Save the invitation in the session, as the user may navigate to another page and lose their key.
      session[:invitation_or_pending_account] = @invitation_or_pending_account if @invitation_or_pending_account
        
    end

    # No invitation or pending account, kick them back to the login page.
    if !@invitation_or_pending_account then
      flash[:notice] = "We are unable to process your request at this time. If the problem persists, <a href=\"#{contact_path}\">let us know</a>."
      redirect_to new_session_path
    end
    
  end

end
