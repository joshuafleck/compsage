# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'front'
  
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
  end

	#TODO: means for loggining in with an invitation. Possibly check params for presence of a key.
  def create
    self.current_organization = Organization.authenticate(params[:email], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_organization.remember_me
        cookies[:auth_token] = { :value => self.current_organization.remember_token , :expires => self.current_organization.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      render :action => 'new'
    end
  end

  def destroy
    self.current_organization.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  #This method is for creating a session when the user is responding to a survey with an External Survey Invitation
  def create_survey_session
    self.current_survey_invitation = ExternalSurveyInvitation.find_by_key(params[:key])
    redirect_to survey_path(self.current_survey_invitation.survey)
  end
end
