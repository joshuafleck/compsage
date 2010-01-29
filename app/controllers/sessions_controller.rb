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
    @login       = params[:email]
    @remember_me = params[:remember_me]
    organization = Organization.authenticate(@login, params[:password])
    
    if organization
      # We do not allow disabled accounts to sign in
      if organization.disabled? then        
        note_disabled_signin(organization)
        redirect_to new_session_path
      else
        new_cookie_flag = (@remember_me == "1")
        login_organization({
            :organization => organization, 
            :new_cookie_flag => new_cookie_flag, 
            :url => '/'})
      end
      
    else
      note_failed_signin
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
    
      survey_url = survey_path(invitation.survey_id)
      
      if invitation.is_a?(ExternalSurveyInvitation) then
        # External survey invitation logins are saved in the session, and users have restricted access
        self.current_survey_invitation = invitation
        redirect_to survey_url
      else
        # Internal survey invitation logins authenticate the organization 
        #  as if they logged in from the login page
        organization = invitation.invitee
        login_organization({
          :organization => organization, 
          :new_cookie_flag => false, 
          :url => survey_url})
      end
      
    else
      note_failed_survey_signin
      render :action => 'new'     
    end
  end

protected

  # Track failed survey login attempts
  def note_failed_survey_signin
    flash.now[:error] = "We are unable to process your request at this time. If the problem persists, "\
                        "<a href=\"#{contact_path}\"> let us know</a>."
    logger.warn "Failed survey login for key:#{params[:key]} at #{Time.now.utc}"
  end  

end
