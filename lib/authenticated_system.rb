module AuthenticatedSystem
  protected
    # Returns true or false if the organization is logged in.
    # Preloads @current_organization with the organization model if they're logged in.
    def logged_in?
      current_organization != :false
    end

    # returns true if the user is logged in with an external invitation.
    def invited_to_survey?
      current_survey_invitation != :false && current_survey_invitation.survey.id == (params[:survey_id] || params[:id]).to_i
    end
    
    # Accesses the current organization from the session.  Set it to :false if login fails
    # so that future calls do not hit the database.
    def current_organization
      @current_organization ||= (login_from_session || login_from_basic_auth || login_from_cookie || :false)
    end

    # Accesses the current survey invitation from the session.  Set it to :false if login fails
    # so that future calls do not hit the database.
    def current_survey_invitation
      @current_survey_invitation ||= (login_from_survey_invitation || :false)
    end
    
    # Accesses the current organization or survey invitation from the session.  Set it to :false if login fails
    # so that future calls do not hit the database.    
    def current_organization_or_survey_invitation
      @current_organization_or_survey_invitation ||= (login_from_session || login_from_basic_auth || login_from_cookie || login_from_survey_invitation || :false)
    end
    
    # Store the given organization id in the session.
    def current_organization=(new_organization)
      session[:organization_id] = (new_organization.nil? || new_organization.is_a?(Symbol)) ? nil : new_organization.id
      @current_organization = new_organization || :false
    end

    # Store the given external survey invitation id in the session
    def current_survey_invitation=(new_invitation)
      session[:external_survey_invitation_id] = (new_invitation.nil? || new_invitation.is_a?(Symbol)) ? nil : new_invitation.id
      @current_survey_invitation = new_invitation || :false
    end
    
    # Check if the organization is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the organization
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_organization.login != "bob"
    #  end
    def authorized?
      logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end

    def login_or_survey_invitation_required
      authorized? || invited_to_survey? || access_denied
    end
    
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the organization is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to login_path
        end
        format.any do
          request_http_basic_authentication 'Web Password'
        end
      end
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    # Inclusion hook to make #current_organization and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_organization, :current_survey_invitation, :current_organization_or_survey_invitation, :logged_in?, :invited_to_survey?
    end

    # Called from #current_organization.  First attempt to login by the organization id stored in the session.
    def login_from_session
      self.current_organization = Organization.find(session[:organization_id]) if session[:organization_id]
    end

    # Called from #current_organization.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_organization = Organization.authenticate(username, password)
      end
    end

    # Called from #current_organization.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      organization = cookies[:auth_token] && Organization.find_by_remember_token(cookies[:auth_token])
      if organization && organization.remember_token?
        organization.remember_me
        cookies[:auth_token] = { :value => organization.remember_token, :expires => organization.remember_token_expires_at }
        self.current_organization = organization
      end
    end
    
    def login_from_survey_invitation
      self.current_survey_invitation = ExternalSurveyInvitation.find(session[:external_survey_invitation_id]) if session[:external_survey_invitation_id]
    end
end
