# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'front'
  filter_parameter_logging :password  
  # render new.rhtml
  def new
    @login = params[:email]
  end

  def create
    logout_keeping_session!
    organization = Organization.authenticate(params[:email], params[:password])
    if organization
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session

      # Set first_login in the session so we can show a tutorial if the user is new.
      session[:first_login] = true if organization.last_login_at.nil?
      
      organization.last_login_at = Time.now
      organization.save

      self.current_organization = organization
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
    else
      note_failed_signin
      @login       = params[:email]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    redirect_back_or_default('/')
  end
  
  def create_survey_session
    logout_keeping_session!
    invitation = Invitation.find_by_key(params[:key])     
    if invitation then
      # check to see if the external invite exists, it could have been replaced by a survey invite if the user created an account
      if invitation.is_a?(ExternalSurveyInvitation) then
        self.current_survey_invitation = invitation
        redirect_to survey_path(self.current_survey_invitation.survey_id)
      else
        @login = invitation.invitee.email
        render :action => 'new'
      end
    else
      note_failed_survey_signin
      render :action => 'new'     
    end
  end
protected
  # Track failed login attempts
  def note_failed_signin
    flash.now[:error] = "Incorrect email or password."
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  # Track failed survey login attempts
  def note_failed_survey_signin
    flash.now[:notice] = "We couldn't log you in using the key provided"
    logger.warn "Failed survey login for key:#{params[:key]} at #{Time.now.utc}"
  end  
end
