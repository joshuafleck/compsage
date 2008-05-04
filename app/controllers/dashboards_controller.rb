class DashboardsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def show
    @page_title = "Dashboard"
    
    @recent_survey_invitations = current_organization.survey_invitations.recent
    @recent_network_invitations = current_organization.network_invitations.recent
    @recent_running_surveys = current_organization.surveys.recently_created
    @recent_completed_surveys = current_organization.participated_surveys.recently_ended
  end
end
