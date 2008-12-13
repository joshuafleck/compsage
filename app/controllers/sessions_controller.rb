# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'front'

  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    organization = Organization.authenticate(params[:email], params[:password])
    if organization
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
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
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  def create_survey_session
    logout_keeping_session!
    self.current_survey_invitation = ExternalSurveyInvitation.find_by_key(params[:key])
    redirect_to survey_path(self.current_survey_invitation.survey_id)
  end
protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "We couldn't log you in as '#{params[:email]}'"
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
