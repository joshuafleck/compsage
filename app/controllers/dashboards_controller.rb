class DashboardsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def show
    @page_title = "Dashboard"
    
    @recent_survey_invitations = current_organization.survey_invitations.recent
    @recent_network_invitations = current_organization.network_invitations.recent
    @recent_running_surveys = current_organization.surveys.open.recent
    @recent_completed_surveys = current_organization.participated_surveys.closed.recent
  end
end
