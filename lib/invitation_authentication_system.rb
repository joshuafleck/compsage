module InvitationAuthenticationSystem

protected

  def self.included(base)
    base.send :helper_method, :logged_in_from_survey_invitation?, :current_organization_or_survey_invitation,
      :current_survey_invitation, :invited_to_survey? if base.respond_to? :helper_method
  end

  def logged_in_from_survey_invitation?
    !!current_survey_invitation
  end

  # Store the given external survey invitation id in the session
  def current_survey_invitation=(new_invitation)
    session[:external_survey_invitation_id] = (new_invitation.nil? || new_invitation.is_a?(Symbol)) ? nil : new_invitation.id
    @current_survey_invitation = new_invitation || false
  end
  
  # Accesses the current survey invitation from the session.  Set it to :false if login fails
  # so that future calls do not hit the database.
  def current_survey_invitation
    @current_survey_invitation ||= (login_from_survey_invitation || false)
  end

  def login_from_survey_invitation
    self.current_survey_invitation = ExternalSurveyInvitation.find(session[:external_survey_invitation_id]) if session[:external_survey_invitation_id]
  end

  def login_or_survey_invitation_required
    authorized? || invited_to_survey? || access_denied
  end

  # returns true if the user is logged in with an external invitation.
  def invited_to_survey?
    current_survey_invitation != false && current_survey_invitation.survey.id == (params[:survey_id] || params[:id]).to_i
  end

  # Accesses the current organization or survey invitation from the session.  Set it to :false if login fails
  # so that future calls do not hit the database.    
  def current_organization_or_survey_invitation
    @current_organization_or_survey_invitation ||= (login_from_session || login_from_cookie || login_from_survey_invitation || :false)
  end
end
