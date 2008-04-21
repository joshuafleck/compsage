class DashboardsController < ApplicationController
  before_filter :login_required
  def show
    @recent_survey_invitations = current_organization.survey_invitations.recent
    @recent_network_invitations = current_organization.network_invitations.recent
    @recent_running_surveys = current_organization.recent_running_surveys
    @recent_completed_surveys = current_organization.recent_completed_surveys
  end
end
