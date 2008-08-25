class DashboardsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'
  
  def show
    @recent_survey_invitations = current_organization.survey_invitations.running.recent
    @recent_network_invitations = current_organization.network_invitations.recent
    @recent_running_surveys = current_organization.sponsored_surveys.running.recent
    @recent_completed_surveys = current_organization.participated_surveys.finished.recent
  end
end
