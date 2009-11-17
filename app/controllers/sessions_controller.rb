class SessionsController < ApplicationController
  layout 'front'
  filter_parameter_logging :password  
  ssl_required :create

  def new
    @login = params[:email]
    @form_options = Rails.env.production? ? {:protocol => 'https://', :host => 'www.compsage.com', :only_path => false} : {}
  end

  def create
    logout_keeping_session!
    organization = Organization.authenticate(params[:email], params[:password])
    if organization
      login_organization(organization)
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
      if invitation.is_a?(ExternalSurveyInvitation) then
        # External survey invitation logins are saved in the session, and users have restricted access
        self.current_survey_invitation = invitation
      else
        # Internal survey invitation logins authenticate the organization as if they logged in from the login page
        organization = invitation.invitee
        login_organization(organization)
      end
      
      redirect_to survey_path(invitation.survey_id)
    else
      note_failed_survey_signin
      render :action => 'new'     
    end
  end

protected

  # Track failed login attempts
  def note_failed_signin
    flash.now[:error] = "Incorrect email or password"
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  # Track failed survey login attempts
  def note_failed_survey_signin
    flash.now[:error] = "We are unable to process your request at this time. If the problem persists, "\
                        "<a href=\"#{contact_path}\"> let us know</a>."
    logger.warn "Failed survey login for key:#{params[:key]} at #{Time.now.utc}"
  end  
  
  # Saves the organization in the session, sets last login date
  def login_organization(organization)
      # Set first_login in the session so we can show a tutorial if the user is new.
      session[:first_login] = true if organization.last_login_at.nil?
      
      organization.last_login_at = Time.now
      organization.save

      self.current_organization = organization
  end
end
